# encoding: ascii-8bit

# Minimal Mission Control Protocol microservice. This service exposes a very
# small HTTP API which translates MCP style requests into existing COSMOS API
# calls. It supports sending commands and retrieving telemetry using the
# existing API helper methods. Authentication is performed using AuthModel so a
# valid COSMOS token must be supplied with each request.

require 'openc3/microservices/microservice'
require 'openc3/api/api'
require 'openc3/models/auth_model'
require 'webrick'
require 'json'

module OpenC3
  # Simple HTTP based MCP adapter. It listens for JSON encoded MCP requests on
  # a configurable port and forwards them to the COSMOS API.
  class McpMicroservice < Microservice
    include Api

    def initialize(name)
      super(name)

      @port = (@config['port'] || ENV['MCP_PORT'] || 7660).to_i
      @route_prefix = @config['route_prefix'] || '/mcp'
      @server = nil
    end

    # Start the WEBrick HTTP server and mount the MCP endpoints.
    def run
      @server = WEBrick::HTTPServer.new(:Port => @port, :BindAddress => '0.0.0.0')
      @logger.info("MCP service listening on port #{@port}")

      @server.mount_proc(File.join(@route_prefix, 'cmd')) do |req, res|
        handle_cmd(req, res)
      end

      @server.mount_proc(File.join(@route_prefix, 'tlm')) do |req, res|
        handle_tlm(req, res)
      end

      trap('INT') { @server.shutdown }
      trap('TERM') { @server.shutdown }
      @server.start
    end

    # Handle a command request. Expects JSON of the form:
    #   {"token":"...","target":"TGT","command":"CMD","params":{...}}
    def handle_cmd(req, res)
      data = parse_request(req, res)
      return unless data

      cmd(data['target'], data['command'], **(data['params'] || {}))
      res.body = {status: 'OK'}.to_json
    rescue => err
      @logger.error("MCP command error: #{err.formatted}")
      res.status = 500
      res.body = {error: err.message}.to_json
    end

    # Handle telemetry requests. Query parameters should contain 'target',
    # 'packet' and 'item'.
    def handle_tlm(req, res)
      data = parse_request(req, res, query: true)
      return unless data

      value = tlm(data['target'], data['packet'], data['item'])
      res.body = {status: 'OK', value: value}.to_json
    rescue => err
      @logger.error("MCP telemetry error: #{err.formatted}")
      res.status = 500
      res.body = {error: err.message}.to_json
    end

    # Parse the request body or query string and verify authentication token.
    def parse_request(req, res, query: false)
      token = req.header['x-cosmos-token']&.first || req.query['token']
      unless OpenC3::AuthModel.verify(token)
        res.status = 401
        res.body = {error: 'Unauthorized'}.to_json
        return nil
      end

      if query
        return req.query
      else
        begin
          return JSON.parse(req.body)
        rescue JSON::ParserError => e
          res.status = 400
          res.body = {error: 'Invalid JSON'}.to_json
          return nil
        end
      end
    end

    def shutdown(state = 'STOPPED')
      @server&.shutdown
      super(state)
    end
  end
end

OpenC3::McpMicroservice.run if __FILE__ == $0

