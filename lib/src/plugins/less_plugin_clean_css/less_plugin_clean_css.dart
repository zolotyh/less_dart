library less_plugin_clean_css.plugins.less;

import '../plugins.dart';
import '../../less_options.dart';
import '../../output.dart';
import '../../environment/environment.dart';
import '../../tree/tree.dart';
import '../../visitor/visitor_base.dart';

part 'clean_css_compatibility.dart';
part 'clean_css_context.dart';
part 'clean_css_options.dart';
part 'clean_css_processor.dart';
part 'clean_css_visitor.dart';

class LessPluginCleanCss extends Plugin {
  CleanCssOptions cleanCssOptions;

  @override List<int> minVersion = <int>[2, 1, 0];

  ///
  LessPluginCleanCss(): super();

  ///
  @override
  void install(PluginManager pluginManager) {
    if (cleanCssOptions == null) setOptions('');
    lessOptions.cleanCss = true;

    final VisitorBase cleanCssVisitor = new CleanCssVisitor(cleanCssOptions);
    pluginManager.addVisitor(cleanCssVisitor);

    final Processor cleanCssProcessor = new CleanCssProcessor(cleanCssOptions);
    pluginManager.addPostProcessor(cleanCssProcessor, 1500);

//2.4.0
//  install: function(less, pluginManager) {
//      var CleanCSSProcessor = getCleanCSSProcessor(less);
//      pluginManager.addPostProcessor(new CleanCSSProcessor(this.options));
//  },
  }

  ///
  @override
  void printUsage() {
    logger.log('');
    logger.log('Clean CSS Plugin');
    logger.log('specify plugin with --clean-css');
    logger.log('To pass an option to clean css, we use similar CLI arguments as from https://github.com/GoalSmashers/clean-css');
    logger.log('The exception is advanced and rebase - we turn these off by default so use advanced/rebase to turn it back on again.');
    logger.log('--clean-css="-s1 --advanced --rebase"');
    logger.log('The options do not require dashes, so this is also equivalent');
    logger.log('--clean-css="s1 advanced rebase"');
    printOptions();
    logger.log('');
  }

  ///
  @override
  void printOptions() {
    logger.log("we support the following arguments... 'keep-line-breaks', 'b'");
    logger.log("'s0', 's1', 'advanced', 'rebase', 'keepSpecialComments', compatibility', 'rounding-precision'");
    logger.log("'skip-aggressive-merging', 'skip-shorthand-compacting'");
  }

  ///
  @override
  void setOptions(String cmdOptions) {
    this.cleanCssOptions = new CleanCssOptions(normalizeCommand(cmdOptions));
  }
}
