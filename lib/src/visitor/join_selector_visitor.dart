//source: less/join-selector-visitor.js 2.3.1

part of visitor.less;

class JoinSelectorVisitor extends VisitorBase{
  List contexts;
  Visitor _visitor;

  ///
  //2.3.1 ok
  JoinSelectorVisitor() {
    this.contexts = [[]];
    this._visitor = new Visitor(this);

//2.3.1
//  var JoinSelectorVisitor = function() {
//      this.contexts = [[]];
//      this._visitor = new Visitor(this);
//  };
  }

  ///
  //2.3.1 ok
  Node run(Node root) => this._visitor.visit(root);

//2.3.1
//  run: function (root) {
//      return this._visitor.visit(root);
//  },

  ///
  //2.3.1 ok
  void visitRule(Rule ruleNode, VisitArgs visitArgs) {
    visitArgs.visitDeeper = false;

//2.3.1
//  visitRule: function (ruleNode, visitArgs) {
//      visitArgs.visitDeeper = false;
//  },
  }

  ///
  //2.3.1
  void visitMixinDefinition(MixinDefinition mixinDefinitionNode, VisitArgs visitArgs) {
    visitArgs.visitDeeper = false;

//2.3.1
//  visitMixinDefinition: function (mixinDefinitionNode, visitArgs) {
//      visitArgs.visitDeeper = false;
//  },
  }

  ///
  //2.3.1 ok
  void visitRuleset(Ruleset rulesetNode, VisitArgs visitArgs) {
    List context = this.contexts.last;
    List paths = [];
    List<Node> selectors;

    this.contexts.add(paths);

    if (!rulesetNode.root) {
      selectors = rulesetNode.selectors;
      if (selectors != null) {
        selectors.retainWhere((selector) => selector.getIsOutput());
        rulesetNode.selectors = selectors.isNotEmpty ? selectors : (selectors = null);
        if (selectors != null) rulesetNode.joinSelectors(paths, context, selectors);
      }
      if (selectors == null) rulesetNode.rules = null;
      rulesetNode.paths = paths;
    }

//2.3.1
//  visitRuleset: function (rulesetNode, visitArgs) {
//      var context = this.contexts[this.contexts.length - 1],
//          paths = [], selectors;
//
//      this.contexts.push(paths);
//
//      if (! rulesetNode.root) {
//          selectors = rulesetNode.selectors;
//          if (selectors) {
//              selectors = selectors.filter(function(selector) { return selector.getIsOutput(); });
//              rulesetNode.selectors = selectors.length ? selectors : (selectors = null);
//              if (selectors) { rulesetNode.joinSelectors(paths, context, selectors); }
//          }
//          if (!selectors) { rulesetNode.rules = null; }
//          rulesetNode.paths = paths;
//      }
//  },
  }

  ///
  //2.3.1 ok
  void visitRulesetOut(Ruleset rulesetNode) {
    this.contexts.removeLast();

//2.3.1
//  visitRulesetOut: function (rulesetNode) {
//      this.contexts.length = this.contexts.length - 1;
//  },
  }

  ///
  //2.3.1 ok
  void visitMedia(Media mediaNode, VisitArgs visitArgs) {
    List context = this.contexts.last;
    (mediaNode.rules[0] as Ruleset).root = (context.isEmpty || (context[0] is Ruleset && (context[0] as Ruleset).multiMedia));

//2.3.1
//  visitMedia: function (mediaNode, visitArgs) {
//      var context = this.contexts[this.contexts.length - 1];
//      mediaNode.rules[0].root = (context.length === 0 || context[0].multiMedia);
//  }
  }

  /// func visitor.visit distribuitor
  Function visitFtn(Node node) {
    if (node is Media) return this.visitMedia;
    if (node is MixinDefinition) return this.visitMixinDefinition;
    if (node is Rule) return this.visitRule;
    if (node is Ruleset) return this.visitRuleset;

    return null;
  }

  /// funcOut visitor.visit distribuitor
  Function visitFtnOut(Node node) {
    if (node is Ruleset) return this.visitRulesetOut;

    return null;
  }
}