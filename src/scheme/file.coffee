fs		= require "fs"
path	= require "path"
Signal	= require "signals"

module.exports = class File


	connection	: null
	connected	: null
	failed		: null
	closed		: null

	constructor: ->
		@connected	= new Signal()
		@failed		= new Signal()
		@closed		= new Signal()

	###
	Connect to the File

	@param config <object> Configuration file for your connection
	###
	connect: (config) ->
		@basePath   = config.basePath
		@connected.dispatch()

	###
	Close the connection
	###
	close: (callback) ->
		@closed.dispatch()

	###
	Dispose
	###
	dispose: ->

	###
	Retrieve a file on the server

	@param path: <string> The path of your file
	@param callback: <function> Callback method
	###
	get: (filePath, callback) ->
		fs.readFile (path.join @basePath, filePath), 'utf8', callback

	###
	Upload a file to the server

	@param local_path: <string> The local path of your file
	@param remote_path: <string> The remote path where you want your file to be uploaded at
	@param callback: <function> Callback method
	###
	upload: (local_path, remote_path, callback) ->
		targetPath = path.join @basePath, remote_path
		targetDir = path.dirname targetPath
		mkdirRecursive targetDir if not fs.existsSync targetDir
		reader = fs.createReadStream local_path
		reader.on "end", callback
		reader.pipe fs.createWriteStream targetPath

	###
	Delete a file from the server

	@param remote_path: <string> The remote path you want to delete
	@param callback: <function> Callback method
	###
	delete: (remote_path, callback) ->
		fs.unlink (path.join @basePath, remote_path), callback

	###
	Create a directory

	@param path: <string> The path of the directory you want to create
	@param callback: <function> Callback method
	###
	mkdir: (remote_path, callback) ->
		mkdirRecursive path.join @basePath, remote_path
		callback()

mkdirRecursive = (targetDir) ->
	(targetDir.split path.sep).forEach (dir, index, splits) ->
		parent = (splits.slice 0, index).join path.sep
		dirPath = path.resolve parent, dir
		fs.mkdirSync dirPath if not fs.existsSync dirPath
