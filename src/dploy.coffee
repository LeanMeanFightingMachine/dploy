colors	= require "colors"

Deploy = require "./deploy"
Generator = require "./generator"
Help = require "./help"
Version = require "./version"

module.exports = class DPLOY

	servers			: null
	connection		: null
	ignoreInclude	: false
	catchup			: false

	###
	DPLOY
	If you set a custom config file for DPLOY
	It will use this config instead of trying to load a dploy.yaml file
	
	@param 	config (optional)		Custom config file of a server to deploy at
	@param 	completed (optional)	Callback for when the entire proccess is completed
	###
	constructor: (@config, @completed) ->
		# DPLOY if there's a custom config
		if @config
			@servers = [null]
			return @deploy()
		# Call the DPLOY generator
		else if process.argv.indexOf("install") >= 0
			return new Generator()
		# Open the help
		else if (process.argv.indexOf("--help") >= 0 or process.argv.indexOf("-h") >= 0)
			return new Help()
		# Print version
		else if process.argv.indexOf("--version") >= 0 or process.argv.indexOf("-v") >= 0
			return new Version()
		# Deploy
		else
			@servers = process.argv.splice(2, process.argv.length)
			# Check if we should ignore the include parameter for this deploy
			@ignoreInclude = @servers.indexOf("-i") >= 0 or @servers.indexOf("--ignore-include") >= 0
			# Check if we should catchup with the server and only upload the revision file
			@catchup = @servers.indexOf("-c") >= 0 or @servers.indexOf("--catchup") >= 0
			# Filter the flags from the server names
			@servers = @_filterFlags @servers, ["-i", "--ignore-include", "-c", "--catchup"]
			# If you don't set any servers, add an empty one to upload the first environment only
			@servers.push null if @servers.length is 0

			@deploy()

	deploy: =>
		# Dispose the current connection
		if @connection
			@connection.dispose()
			@connection = null

		# Keep deploying until all servers are updated
		if @servers.length
			@connection = new Deploy @config, @servers[0], @ignoreInclude, @catchup
			@connection.completed.add @deploy
			@servers.shift()
		# Finish the process
		else
			console.log "All Completed :)".green.bold
			if @completed
				@completed.call(@)
			else
				process.exit(code=0)

		return @


	_filterFlags: (servers, flags) ->
		servers = servers.filter (value) ->
			valid = true
			flags.forEach (flag) -> valid = false if flag is value
			return valid
		servers