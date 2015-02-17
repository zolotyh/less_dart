// source: less/import-visitor.js 2.3.1

part of visitor.less;

class ImportVisitor extends VisitorBase {
  ImportManager   importer;

  Contexts        context;
  bool            isReplacing = false;
  LessError       lessError;
  ImportDetector  onceFileDetectionMap;
  ImportDetector  recursionDetector;
  Visitor         _visitor;

  /// visitImport futures for await their completion
  List<Future> runners = [];


  ///
  /// Structure to search for @import in the tree.
  ///
  //2.3.1
  ImportVisitor(ImportManager this.importer, [Contexts context, ImportDetector onceFileDetectionMap, ImportDetector recursionDetector]) {
    this._visitor = new Visitor(this);
    this.context = (context != null) ? context : new Contexts.eval();

    this.onceFileDetectionMap = ImportDetector.own(onceFileDetectionMap);
    this.recursionDetector = ImportDetector.clone(recursionDetector); //own?

//2.3.1
//  var ImportVisitor = function(importer, finish) {
//      this._visitor = new Visitor(this);
//      this._importer = importer;
//      this._finish = finish;
//      this.context = new contexts.Eval();
//      this.importCount = 0;
//      this.onceFileDetectionMap = {};
//      this.recursionDetector = {};
//      this._sequencer = new ImportSequencer(this._onSequencerEmpty.bind(this));
//  };
  }

  ///
  /// Replaces @import nodes with the file content
  ///
  //2.3.1 ok
  Future run(Node root) {
    this._visitor.visit(root);
    return Future
        .wait(runners, eagerError: true)
        .catchError((e) {
          return new Future.error(e);
        });

//2.3.1
//  run: function (root) {
//      try {
//          // process the contents
//          this._visitor.visit(root);
//      }
//      catch(e) {
//          this.error = e;
//      }
//
//      this.isFinished = true;
//      this._sequencer.tryRun();
//  }
  }

////2.3.1
////  _onSequencerEmpty: function() {
////      if (!this.isFinished) {
////          return;
////      }
////      this._finish(this.error);
////  },
//  }

  ///
  /// @import node - recursively load file and parse
  ///
  //2.3.1 ok
  visitImport(Import importNode, VisitArgs visitArgs) {
    bool inlineCSS = isTrue(importNode.options.inline); //include the file, but not process

    if (!importNode.css || inlineCSS) {
      Contexts context = new Contexts.eval(this.context, this.context.frames.sublist(0));
      Node importParent = context.frames[0];
      this.processImportNode(importNode, context, importParent);
    }

    visitArgs.visitDeeper = false;

//2.3.1
//  visitImport: function (importNode, visitArgs) {
//      var inlineCSS = importNode.options.inline;
//
//      if (!importNode.css || inlineCSS) {
//
//          var context = new contexts.Eval(this.context, this.context.frames.slice(0));
//          var importParent = context.frames[0];
//
//          this.importCount++;
//          if (importNode.isVariableImport()) {
//              this._sequencer.addVariableImport(this.processImportNode.bind(this, importNode, context, importParent));
//          } else {
//              this.processImportNode(importNode, context, importParent);
//          }
//      }
//      visitArgs.visitDeeper = false;
//  },
  }

  ///
  //2.3.1 ok
  processImportNode(Import importNode, Contexts context, Node importParent) {
    Completer completer = new Completer();
    runners.add(completer.future);

    Import evaldImportNode;
    bool inlineCSS = isTrue(importNode.options.inline);

    try {
      //expand @variables in path value, ...
      evaldImportNode = importNode.evalForImport(context);
    } catch (e) {
        LessError error = LessError.transform(e,
            filename: importNode.currentFileInfo.filename,
            index: importNode.index);
        // attempt to eval properly and treat as css
        importNode.css = true;
        // if that fails, this error will be thrown
        importNode.errorImport = error;
    }

    if (evaldImportNode != null && (!evaldImportNode.css || inlineCSS)) {
      if (isTrue(evaldImportNode.options.multiple)) context.importMultiple = true;

      // try appending if we haven't determined if it is css or not
      bool tryAppendLessExtension = !evaldImportNode.css;

      for (int i = 0; i < importParent.rules.length; i++) {
        if (importParent.rules[i] == importNode) {
          importParent.rules[i] = evaldImportNode;
          break;
        }
      }
      this.importer.push(evaldImportNode.getPath(), tryAppendLessExtension, evaldImportNode.currentFileInfo,
          evaldImportNode.options).then((ImportedFile importedFile){
        onImported(evaldImportNode, context, importedFile.root, importedFile.importedPreviously,
            importedFile.fullPath).then((_){
          completer.complete();
        })
        .catchError((e) {
          completer.completeError(e);
         });
      }).catchError((e, s){
        LessError error = LessError.transform(e,
          index: evaldImportNode.index,
          filename: evaldImportNode.currentFileInfo.filename,
          context: context,
          stackTrace: s);
        this.lessError = error;
        completer.completeError(error);
      });
    } else {
      completer.complete();
    }


//2.3.1
//  processImportNode: function(importNode, context, importParent) {
//      var evaldImportNode,
//          inlineCSS = importNode.options.inline;
//
//      try {
//          evaldImportNode = importNode.evalForImport(context);
//      } catch(e){
//          if (!e.filename) { e.index = importNode.index; e.filename = importNode.currentFileInfo.filename; }
//          // attempt to eval properly and treat as css
//          importNode.css = true;
//          // if that fails, this error will be thrown
//          importNode.error = e;
//      }
//
//      if (evaldImportNode && (!evaldImportNode.css || inlineCSS)) {
//
//          if (evaldImportNode.options.multiple) {
//              context.importMultiple = true;
//          }
//
//          // try appending if we haven't determined if it is css or not
//          var tryAppendLessExtension = evaldImportNode.css === undefined;
//
//          for(var i = 0; i < importParent.rules.length; i++) {
//              if (importParent.rules[i] === importNode) {
//                  importParent.rules[i] = evaldImportNode;
//                  break;
//              }
//          }
//
//          var onImported = this.onImported.bind(this, evaldImportNode, context),
//              sequencedOnImported = this._sequencer.addImport(onImported);
//
//          this._importer.push(evaldImportNode.getPath(), tryAppendLessExtension, evaldImportNode.currentFileInfo,
//              evaldImportNode.options, sequencedOnImported);
//      } else {
//          this.importCount--;
//          if (this.isFinished) {
//              this._sequencer.tryRun();
//          }
//      }
//  },
  }

  ///
  /// Recursively analyze the imported root for more imports
  /// [root] is String or Ruleset
  ///
  //2.3.1 ok
  Future onImported(Import importNode, Contexts context, root, bool importedAtRoot, String fullPath) {
    Completer completer = new Completer();
    ImportVisitor importVisitor = this;
    bool inlineCSS = isTrue(importNode.options.inline);
    bool duplicateImport = importedAtRoot || recursionDetector.containsKey(fullPath);

    if(!isTrue(context.importMultiple)) {
      if (duplicateImport) {
        importNode.skip = true;
      } else {
        // define function
        importNode.skip = () {
          if (importVisitor.onceFileDetectionMap.containsKey(fullPath)) return true;
          importVisitor.onceFileDetectionMap[fullPath] = true;
          return false;
        };
      }
    }

    // recursion - analyze the new root
    if (root != null) {
      importNode.root = root;
      importNode.importedFilename = fullPath;

      if (!inlineCSS && (isTrue(context.importMultiple) || !duplicateImport)) {
        recursionDetector[fullPath] = true;
        new ImportVisitor(this.importer, context, onceFileDetectionMap, recursionDetector).run(root).then((_){
          completer.complete();
        }).catchError((e){
          completer.completeError(e);
        });
      } else {
        completer.complete();
      }
    } else {
      completer.complete();
    }

    return completer.future;

//2.3.1
//  onImported: function (importNode, context, e, root, importedAtRoot, fullPath) {
//      if (e) {
//          if (!e.filename) {
//              e.index = importNode.index; e.filename = importNode.currentFileInfo.filename;
//          }
//          this.error = e;
//      }
//
//      var importVisitor = this,
//          inlineCSS = importNode.options.inline,
//          duplicateImport = importedAtRoot || fullPath in importVisitor.recursionDetector;
//
//      if (!context.importMultiple) {
//          if (duplicateImport) {
//              importNode.skip = true;
//          } else {
//              importNode.skip = function() {
//                  if (fullPath in importVisitor.onceFileDetectionMap) {
//                      return true;
//                  }
//                  importVisitor.onceFileDetectionMap[fullPath] = true;
//                  return false;
//              };
//          }
//      }
//
//      if (root) {
//          importNode.root = root;
//          importNode.importedFilename = fullPath;
//
//          if (!inlineCSS && (context.importMultiple || !duplicateImport)) {
//              importVisitor.recursionDetector[fullPath] = true;
//
//              var oldContext = this.context;
//              this.context = context;
//              try {
//                  this._visitor.visit(root);
//              } catch (e) {
//                  this.error = e;
//              }
//              this.context = oldContext;
//          }
//      }
//
//      importVisitor.importCount--;
//
//      if (importVisitor.isFinished) {
//          importVisitor._sequencer.tryRun();
//      }
//  },
  }


  ///
  //2.3.1 ok
  visitRule(Rule ruleNode, VisitArgs visitArgs) {
    visitArgs.visitDeeper = false;

//2.3.1
//  visitRule: function (ruleNode, visitArgs) {
//      visitArgs.visitDeeper = false;
//  },
  }

  ///
  //2.3.1 ok
  visitDirective(Directive directiveNode, VisitArgs visitArgs) {
    this.context.frames.insert(0, directiveNode);

//2.3.1
//  visitDirective: function (directiveNode, visitArgs) {
//      this.context.frames.unshift(directiveNode);
//  },
  }

  ///
  //2.3.1 ok
  void visitDirectiveOut(Directive directiveNode) {
    this.context.frames.removeAt(0);

//2.3.1
//  visitDirectiveOut: function (directiveNode) {
//      this.context.frames.shift();
//  },
  }

  ///
  //2.3.1 ok
  visitMixinDefinition(MixinDefinition mixinDefinitionNode, VisitArgs visitArgs) {
    this.context.frames.insert(0, mixinDefinitionNode);

//2.3.1
//  visitMixinDefinition: function (mixinDefinitionNode, visitArgs) {
//      this.context.frames.unshift(mixinDefinitionNode);
//  },
  }

  ///
  //2.3.1 ok
  void visitMixinDefinitionOut(MixinDefinition mixinDefinitionNode) {
    this.context.frames.removeAt(0);

//2.3.1
//  visitMixinDefinitionOut: function (mixinDefinitionNode) {
//      this.context.frames.shift();
//  },
  }

  ///
  //2.3.1 ok
  visitRuleset(Ruleset rulesetNode, VisitArgs visitArgs) {
    this.context.frames.insert(0, rulesetNode);

//2.3.1
//  visitRuleset: function (rulesetNode, visitArgs) {
//      this.context.frames.unshift(rulesetNode);
//  },
  }

  ///
  //2.3.1 ok
  void visitRulesetOut(Ruleset rulesetNode) {
    this.context.frames.removeAt(0);

//2.3.1
//  visitRulesetOut: function (rulesetNode) {
//      this.context.frames.shift();
//  },
  }

  ///
  //2.3.1 ok
  visitMedia(Media mediaNode, VisitArgs visitArgs) {
    this.context.frames.insert(0, mediaNode.rules[0]);

//2.3.1
//  visitMedia: function (mediaNode, visitArgs) {
//      this.context.frames.unshift(mediaNode.rules[0]);
//  },
  }

  ///
  //2.3.1 ok
  void visitMediaOut(Media mediaNode) {
    this.context.frames.removeAt(0);

//2.3.1
//  visitMediaOut: function (mediaNode) {
//      this.context.frames.shift();
//  }
  }

  /// func visitor.visit distribuitor
  Function visitFtn(Node node) {
    if (node is Directive)  return this.visitDirective;
    if (node is Import)     return this.visitImport;
    if (node is Media)      return this.visitMedia;
    if (node is MixinDefinition) return this.visitMixinDefinition;
    if (node is Rule)       return this.visitRule;
    if (node is Ruleset)    return this.visitRuleset;

    return null;
  }

  /// funcOut visitor.visit distribuitor
  Function visitFtnOut(Node node) {
    if (node is Directive)  return this.visitDirectiveOut;
    if (node is Media)      return this.visitMediaOut;
    if (node is MixinDefinition) return this.visitMixinDefinitionOut;
    if (node is Ruleset)    return this.visitRulesetOut;

    return null;
  }
}