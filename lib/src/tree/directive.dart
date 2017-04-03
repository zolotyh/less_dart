//source: less/tree/directive.js 2.5.0

part of tree.less;

class Directive extends DirectiveBase {
  @override final String    type = 'Directive';
  @override covariant Node  value;

  Directive(String name, Node this.value, dynamic rules, int index,
      FileInfo currentFileInfo, DebugInfo debugInfo,
      [bool isReferenced = false, bool isRooted = false])
      : super() {
    this.name = name;
    this.index = index;
    this.currentFileInfo = currentFileInfo;
    this.debugInfo = debugInfo;
    this.isReferenced = isReferenced;
    this.isRooted = isRooted;

    if (rules != null) {
      if (rules is List<Ruleset>) {
        this.rules = rules;
      } else {
        this.rules = <Ruleset>[rules as Ruleset];
        this.rules[0].selectors =
            (new Selector(<Element>[], null, null, this.index, currentFileInfo))
                .createEmptySelectors();
      }
      this.rules.forEach((Ruleset rule) {
        rule.allowImports = true;
      });
    }

//2.4.0 20150319
//  var Directive = function (name, value, rules, index, currentFileInfo, debugInfo, isReferenced, isRooted) {
//      var i;
//
//      this.name  = name;
//      this.value = value;
//      if (rules) {
//          if (Array.isArray(rules)) {
//              this.rules = rules;
//          } else {
//              this.rules = [rules];
//              this.rules[0].selectors = (new Selector([], null, null, this.index, currentFileInfo)).createEmptySelectors();
//          }
//          for (i = 0; i < this.rules.length; i++) {
//              this.rules[i].allowImports = true;
//          }
//      }
//      this.index = index;
//      this.currentFileInfo = currentFileInfo;
//      this.debugInfo = debugInfo;
//      this.isReferenced = isReferenced;
//      this.isRooted = isRooted || false;
//  };
  }
}

///
/// Base class for Directive and Media
///
class DirectiveBase extends Node
    with OutputRulesetMixin, VariableMixin
    implements GetIsReferencedNode, MarkReferencedNode {
  @override String                  name;
  @override covariant List<Ruleset> rules; //more restrictive type
  @override String get              type => 'DirectiveBase';

  int   index;
  bool  isReferenced = false;
  bool  isRooted = false;

  DirectiveBase();

  ///
  @override
  void accept(covariant Visitor visitor) {
    if (rules != null) rules = visitor.visitArray(rules);
    if (value != null) value = visitor.visit(value);

//2.4.0+
//  Directive.prototype.accept = function (visitor) {
//      var value = this.value, rules = this.rules;
//      if (rules) {
//          this.rules = visitor.visitArray(rules);
//      }
//      if (value) {
//          this.value = visitor.visit(value);
//      }
//  };
  }

  ///
  @override
  bool isRulesetLike()  => (rules != null) || !isCharset();

//2.3.1
//  Directive.prototype.isRulesetLike = function() {
//      return this.rules || !this.isCharset();
//  };

  ///
  @override
  bool isCharset() => '@charset' == name;

  ///
  @override
  void genCSS(Contexts context, Output output) {
    output.add(name, currentFileInfo, index);

    if (value != null) {
      output.add(' ');
      value.genCSS(context, output);
    }

    if (rules != null) {
      outputRuleset(context, output, rules);
    } else {
      output.add(';');
    }

//2.4.0+1
//  Directive.prototype.genCSS = function (context, output) {
//      var value = this.value, rules = this.rules;
//      output.add(this.name, this.currentFileInfo, this.index);
//      if (value) {
//          output.add(' ');
//          value.genCSS(context, output);
//      }
//      if (rules) {
//          this.outputRuleset(context, output, rules);
//      } else {
//          output.add(';');
//      }
//  };
  }

  ///
  @virtual @override
  Node eval(Contexts context) {
    Node value = this.value;
    List<Ruleset> rules = this.rules;

    // media stored inside other directive should not bubble over it
    // backpup media bubbling information
    final List<Media> mediaPathBackup = context.mediaPath;
    final List<Media> mediaBlocksBackup = context.mediaBlocks;
    // deleted media bubbling information
    context.mediaPath = <Media>[];
    context.mediaBlocks = <Media>[];

    if (value != null) value = value.eval(context);
    if (rules != null) {
      // assuming that there is only one rule at this point - that is how parser constructs the rule
      rules = <Ruleset>[rules[0].eval(context)];
      rules[0].root = true;
    }
    // restore media bubbling information
    context.mediaPath = mediaPathBackup;
    context.mediaBlocks = mediaBlocksBackup;

    return new Directive(name, value, rules,
        index, currentFileInfo, debugInfo, isReferenced, isRooted);

//2.4.0 20150319
//  Directive.prototype.eval = function (context) {
//      var mediaPathBackup, mediaBlocksBackup, value = this.value, rules = this.rules;
//
//      //media stored inside other directive should not bubble over it
//      //backpup media bubbling information
//      mediaPathBackup = context.mediaPath;
//      mediaBlocksBackup = context.mediaBlocks;
//      //deleted media bubbling information
//      context.mediaPath = [];
//      context.mediaBlocks = [];
//
//      if (value) {
//          value = value.eval(context);
//      }
//      if (rules) {
//          // assuming that there is only one rule at this point - that is how parser constructs the rule
//          rules = [rules[0].eval(context)];
//          rules[0].root = true;
//      }
//      //restore media bubbling information
//      context.mediaPath = mediaPathBackup;
//      context.mediaBlocks = mediaBlocksBackup;
//
//      return new Directive(this.name, value, rules,
//          this.index, this.currentFileInfo, this.debugInfo, this.isReferenced, this.isRooted);
//  };
  }

// in VariableMixin - override

  ///
  //untested - no covered by tests
  @override
  Node variable(String name) {
    if (rules?.isNotEmpty ?? false) {
      return rules[0].value(name);
    }
    return null;

//2.4.0+
//  Directive.prototype.variable = function (name) {
//      if (this.rules) {
//          // assuming that there is only one rule at this point - that is how parser constructs the rule
//          return Ruleset.prototype.variable.call(this.rules[0], name);
//      }
//  };
  }

  ///
  //untested - no covered by tests
  // self type?
  @override
  List<MixinFound> find (Selector selector, [dynamic self, Function filter]) {
    if (rules?.isNotEmpty ?? false) {
      // assuming that there is only one rule at this point - that is how parser constructs the rule
      return rules[0].find(selector, self, filter);
    }
    return null;

//2.4.0+
//  Directive.prototype.find = function () {
//      if (this.rules) {
//          // assuming that there is only one rule at this point - that is how parser constructs the rule
//          return Ruleset.prototype.find.apply(this.rules[0], arguments);
//      }
//  };
  }

  ///
  //untested
  @override
  List<Node> rulesets() {
    if (rules?.isNotEmpty ?? false) {
      // assuming that there is only one rule at this point - that is how parser constructs the rule
      return rules[0].rulesets();
    }
    return null;

//2.4.0+
//  Directive.prototype.rulesets = function () {
//      if (this.rules) {
//          // assuming that there is only one rule at this point - that is how parser constructs the rule
//          return Ruleset.prototype.rulesets.apply(this.rules[0]);
//      }
//  };
  }

  //--- MarkReferencedNode

  ///
  @override
  void markReferenced() {
    List<Node> rules;
    isReferenced = true;

    if (this.rules != null) {
      rules = this.rules;
      for (int i = 0; i < rules.length; i++) {
        if (rules[i] is MarkReferencedNode) {
          (rules[i] as MarkReferencedNode).markReferenced();
        }
      }
    }

// 2.4.0+
//  Directive.prototype.markReferenced = function () {
//      var i, rules;
//      this.isReferenced = true;
//      if (this.rules) {
//          rules = this.rules;
//          for (i = 0; i < rules.length; i++) {
//              if (rules[i].markReferenced) {
//                  rules[i].markReferenced();
//              }
//          }
//      }
//  };
  }

  ///
  @override
  bool getIsReferenced() =>
      (currentFileInfo == null) || !currentFileInfo.reference || isReferenced;

//2.3.1
//  Directive.prototype.getIsReferenced = function () {
//      return !this.currentFileInfo || !this.currentFileInfo.reference || this.isReferenced;
//  };
}
