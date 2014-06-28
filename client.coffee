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
	comments = model.createList()
	root.set 'comments', comments

	# alpha_comment = model.createMap
	# 	text: model.createString "First!"

	# comments = model.createList([alpha_comment])
	# root.set 'comments', comments
	return

###
This function is called when the Realtime file has been loaded. It should
be used to initialize any user interface components and event handlers
depending on the Realtime model. In this case, create a text control binder
and bind it to our string model that we created in initializeModel.
@param doc {gapi.drive.realtime.Document} the Realtime document.
###

KEYCODES =
	enter:13
	backspace:8

class Thread
	constructor: ({@model, @node}) ->
		@make_new_comment()
		for comment in @model.asArray()
			@load_comment comment

		@bind_events()

	make_new_comment: ->
		@new_comment = new Comment
			thread: @

	render: ->
		@node = $ '<div class="replies"></div>'

	post: (comment) ->
		@model.push comment.model
		@prior_new_comment = @new_comment
		if comment is @new_comment
			@make_new_comment()

	delete: (comment) ->
		@model.removeValue comment.model
		comment.node.remove()

	bind_events: ->
		@model.addEventListener gapi.drive.realtime.EventType.VALUES_ADDED, (event) =>
			if not event.isLocal
				for comment in event.values
					@load_comment comment

		@model.addEventListener gapi.drive.realtime.EventType.VALUES_REMOVED, (event) =>
			if not event.isLocal
				for comment in event.values
					console.log comment



	load_comment: (comment) ->
		new Comment
			model: comment
			thread: @

class Comment
	constructor: ({@model, @thread}) ->
		@is_persisted = Boolean @model
		@is_fresh = not @is_persisted
		# fresh comments are ones you just started writing.
		# They keep you in the same thread when you hit enter.

		@create_model() if not @model?

		@render()
		@bind_events()

		# track the child thread
		thread_model = @model.get 'thread'
		if thread_model
			@child_thread = new Thread
				model: thread_model
				node: @thread_node


		# if not @model?
		# 	@bind_new_comment_handlers()
		# else
		# 	@bind_basic_handlers()

	create_model: ->
		@model = model.createMap
			text: model.createString()

	render: ->
		@node = $ '<div class="comment"></div>'
		@text_node = $ '<textarea></textarea>'
		@node.append @text_node

		# put it before the new comment node
		if @is_persisted
			@thread.new_comment.node.before @node
		else
			@thread.node.append @node

		# this will be invisible until it is populated
		@thread_node = $ '<div class="thread"></div>'
		@node.append @thread_node

	track_text: ->
		gapi.drive.realtime.databinding.bindString @model.get('text'), @text_node[0]

	bind_events: ->
		if @is_persisted
			@track_text()

		@text_node.on 'keypress', (event) =>
			if event.which is KEYCODES.enter
				event.preventDefault()
				event.stopPropagation()
				if @text_node.val()
					if @is_fresh
						@thread.new_comment.text_node.focus()
						@is_fresh = false
					else
						@start_thread()
			else
				if not @is_persisted
					@make_real()
					# promote to a real comment				

		# backspace refuses to work with keypress, so we must use keyup instead.
		# TODO: make it so it only deletes if it was blank BEFORE the backspace.
		@text_node.on 'keydown', (event) =>
			if event.which is KEYCODES.backspace and @ isnt @thread.new_comment and not @text_node.val()
				@thread.delete @

	make_real: ->
		@thread.post @
		@track_text()
		@is_persisted = true

	start_thread: ->
		thread_model = model.createList()
		@model.set 'thread', thread_model
		@child_thread = new Thread
			model: thread_model
			node: @thread_node

		@child_thread.new_comment.text_node.focus()




register_types = ->
	# gapi.drive.realtime.custom.registerType Comment, 'Comment'
	# Comment.prototype.text = gapi.drive.realtime.custom.collaborativeField 'text'
	# Comment.prototype.replies = gapi.drive.realtime.custom.collaborativeField 'replies'

model = null

onFileLoaded = (doc) ->

	# variables
	thread_node = $(document.body)
	model = doc.getModel()
	root = model.getRoot()
	thread = root.get 'comments'

	# Render
	# wrap the model with things
	new Thread
		model: thread
		node: thread_node

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

startRealtime = ->
	realtimeLoader = new rtclient.RealtimeLoader(realtimeOptions)
	realtimeLoader.start()
	return

realtimeOptions =
	clientId: "750901531017-tr6fb08mn5kacnd1suht48uj8762dkc5.apps.googleusercontent.com"
	authButtonElementId: "authorizeButton"
	initializeModel: initializeModel
	autoCreate: true
	defaultTitle: "New Wave2"
	newFileMimeType: null
	onFileLoaded: onFileLoaded
	registerTypes: register_types
	afterAuth: null

startRealtime()