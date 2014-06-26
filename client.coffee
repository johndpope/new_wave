# class Comment
# gapi.drive.realtime.custom.registerType Comment, 'Comment'
# Comment.prototype.text = gapi.drive.realtime.custom.collaborativeField 'text'
# Comment.prototype.children = gapi.drive.realtime.custom.collaborativeList 'text'


###
This function is called the first time that the Realtime model is created
for a file. This function should be used to initialize any values of the
model. In this case, we just create the single string model that will be
used to control our text box. The string has a starting value of 'Hello
Realtime World!', and is named 'text'.
@param model {gapi.drive.realtime.Model} the Realtime root model object.
###
initializeModel = (model) ->
	# string = model.createString "Hello Realtime World!"
	root = model.getRoot()

	alpha_comment = model.createMap
		text: model.createString "First!"

	comments = model.createList([alpha_comment])
	root.set 'comments', comments
	return

###
This function is called when the Realtime file has been loaded. It should
be used to initialize any user interface components and event handlers
depending on the Realtime model. In this case, create a text control binder
and bind it to our string model that we created in initializeModel.
@param doc {gapi.drive.realtime.Document} the Realtime document.
###

class Comment
	constructor: ->
		@render()
		# This constructor can't take arguments.
		# Instead, all data is side-loaded.
		# It is required that you side-load @thread

	render: ->
		@node = $ '<div class="comment"></div>'
		@text_node = $ '<textarea></textarea>'
		@replies_node = $ '<div class="replies"></div>'
		@node.append @text_node
		@node.append @replies_node

		# Typing immediately posts the comment
		@text_node.one 'keypress', =>
			@thread.push @
			gapi.drive.realtime.databinding.bindString @text, @text_node[0]


register_types = ->
	gapi.drive.realtime.custom.registerType Comment, 'Comment'



onFileLoaded = (doc) ->
	# register comment type
	Comment.prototype.text = gapi.drive.realtime.custom.collaborativeField 'text'
	Comment.prototype.replies = gapi.drive.realtime.custom.collaborativeField 'replies'

	# variables
	thread_node = $(document.body)
	model = doc.getModel()
	root = model.getRoot()

	# Initialize
	comments = model.createList()
	root.set 'comments', comments

	new_comment = model.create 'Comment'
	new_comment.thread = comments
	thread_node.append(new_comment.node)

	# alpha_comment = model.createMap
	# 	text: model.createString "First!"

	# comments = model.createList([alpha_comment])
	# root.set 'comments', comments



	# comments = root.get('comments')
	# for comment in comments.asArray()
	# 	comment_node = $ '<div class="comment"></div>'
	# 	textarea = $ '<textarea></textarea>'
	# 	comment_node.append textarea
	# 	thread_node.append comment_node
	# 	gapi.drive.realtime.databinding.bindString comment.get('text'), textarea[0]



	# model.addEventListener gapi.drive.realtime.EventType.UNDO_REDO_STATE_CHANGED, onUndoRedoStateChanged
	return

###
Options for the Realtime loader.
###

###
Client ID from the console.
###

###
The ID of the button to click to authorize. Must be a DOM element ID.
###

###
Function to be called when a Realtime model is first created.
###

###
Autocreate files right after auth automatically.
###

###
The name of newly created Drive files.
###

###
The MIME type of newly created Drive Files. By default the application
specific MIME type will be used:
application/vnd.google-apps.drive-sdk.
###
# Using default.

###
Function to be called every time a Realtime file is loaded.
###

###
Function to be called to inityalize custom Collaborative Objects types.
###
# No action.

###
Function to be called after authorization and before loading files.
###
# No action.

###
Start the Realtime loader with the options.
###
startRealtime = ->
	realtimeLoader = new rtclient.RealtimeLoader(realtimeOptions)
	realtimeLoader.start()
	return
realtimeOptions =
	clientId: "750901531017-tr6fb08mn5kacnd1suht48uj8762dkc5.apps.googleusercontent.com"
	authButtonElementId: "authorizeButton"
	initializeModel: initializeModel
	autoCreate: true
	defaultTitle: "New Wave"
	newFileMimeType: null
	onFileLoaded: onFileLoaded
	registerTypes: register_types
	afterAuth: null

startRealtime()