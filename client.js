// Generated by CoffeeScript 1.7.1

/*
This function is called the first time that the Realtime model is created
for a file. This function should be used to initialize any values of the
model. In this case, we just create the single string model that will be
used to control our text box. The string has a starting value of 'Hello
Realtime World!', and is named 'text'.
@param model {gapi.drive.realtime.Model} the Realtime root model object.
 */

(function() {
  var initializeModel, onFileLoaded, realtimeOptions, startRealtime;

  initializeModel = function(model) {
    var alpha_comment, comments, root;
    root = model.getRoot();
    alpha_comment = model.createMap({
      text: model.createString("First!")
    });
    comments = model.createList([alpha_comment]);
    root.set('comments', comments);
  };


  /*
  This function is called when the Realtime file has been loaded. It should
  be used to initialize any user interface components and event handlers
  depending on the Realtime model. In this case, create a text control binder
  and bind it to our string model that we created in initializeModel.
  @param doc {gapi.drive.realtime.Document} the Realtime document.
   */

  onFileLoaded = function(doc) {
    var comment, comment_node, comments, model, onUndoRedoStateChanged, redoButton, root, textarea, thread_node, undoButton, _i, _len, _ref;
    model = doc.getModel();
    root = model.getRoot();
    thread_node = $(document.body);
    comments = root.get('comments');
    _ref = comments.asArray();
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      comment = _ref[_i];
      comment_node = $('<div class="comment"></div>');
      textarea = $('<textarea></textarea>');
      comment_node.append(textarea);
      thread_node.append(comment_node);
      gapi.drive.realtime.databinding.bindString(comment.get('text'), textarea[0]);
    }
    undoButton = document.getElementById("undoButton");
    redoButton = document.getElementById("redoButton");
    undoButton.onclick = function(e) {
      model.undo();
    };
    redoButton.onclick = function(e) {
      model.redo();
    };
    onUndoRedoStateChanged = function(e) {
      undoButton.disabled = !e.canUndo;
      redoButton.disabled = !e.canRedo;
    };
    model.addEventListener(gapi.drive.realtime.EventType.UNDO_REDO_STATE_CHANGED, onUndoRedoStateChanged);
  };


  /*
  Options for the Realtime loader.
   */


  /*
  Client ID from the console.
   */


  /*
  The ID of the button to click to authorize. Must be a DOM element ID.
   */


  /*
  Function to be called when a Realtime model is first created.
   */


  /*
  Autocreate files right after auth automatically.
   */


  /*
  The name of newly created Drive files.
   */


  /*
  The MIME type of newly created Drive Files. By default the application
  specific MIME type will be used:
  application/vnd.google-apps.drive-sdk.
   */


  /*
  Function to be called every time a Realtime file is loaded.
   */


  /*
  Function to be called to inityalize custom Collaborative Objects types.
   */


  /*
  Function to be called after authorization and before loading files.
   */


  /*
  Start the Realtime loader with the options.
   */

  startRealtime = function() {
    var realtimeLoader;
    realtimeLoader = new rtclient.RealtimeLoader(realtimeOptions);
    realtimeLoader.start();
  };

  realtimeOptions = {
    clientId: "750901531017-tr6fb08mn5kacnd1suht48uj8762dkc5.apps.googleusercontent.com",
    authButtonElementId: "authorizeButton",
    initializeModel: initializeModel,
    autoCreate: true,
    defaultTitle: "New Wave",
    newFileMimeType: null,
    onFileLoaded: onFileLoaded,
    registerTypes: null,
    afterAuth: null
  };

  startRealtime();

}).call(this);
