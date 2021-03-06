//source: lib/less-node/plugin-loader.js 2.5.0
//source: lib/less/environment/abstract-plugin-loader.js 3.0.0 20160713

part of plugins.less;

///
class PluginLoader {
  ///
  Environment   environment;
  ///
  Logger        logger;
  ///
  LessOptions   options;
  ///
  PluginManager pluginManager;

  /// Plugins to install
  Map<String, Plugin> installable = <String, Plugin>{
    'less-plugin-clean-css': new LessPluginCleanCss(),
    'less-plugin-advanced-color-functions': new LessPluginAdvancedColorFunctions()
  };

  ///
  PluginLoader(this.options) {
    environment = new Environment();
    logger = environment.logger;

//    if (options.pluginManager == null) options.pluginManager = new PluginManager();
//    pluginManager = options.pluginManager;
  }

  ///
  /// Add a [plugin] to list of available plugins, with [name]
  /// Example pluginLoader.define('myPlugin', New MyPlugin());
  ///
  void define(String name, Plugin plugin) {
    installable[name] = plugin;
  }

  ///
  Plugin tryLoadPlugin(String name, String argument) {
    Plugin plugin;
    final String prefix = installable.containsKey(name) ? '' : 'less-plugin-';
    final String pluginName = '$prefix$name';

    if (installable.containsKey(pluginName)) {
      plugin = installable[pluginName];
      if (compareVersion(plugin.minVersion, LessIndex.version) < 0) {
        logger.log('plugin $name requires version ${versionToString(plugin.minVersion)}');
        return null;
      }
      plugin.init(options);

      if (argument != null) {
        try {
          plugin.setOptions(argument);
        } catch (e) {
          logger.log('Error setting options on plugin $name\n${e.toString()}');
          return null;
        }
      }
      return plugin;
    }

    return null;

//2.4.0
//  PluginLoader.prototype.tryLoadPlugin = function(name, argument) {
//      var plugin = this.tryRequirePlugin(name);
//      if (plugin) {
//          // support plugins being a function
//          // so that the plugin can be more usable programmatically
//          if (typeof plugin === "function") {
//              plugin = new plugin();
//          }
//          if (plugin.minVersion) {
//              if (this.compareVersion(plugin.minVersion, this.less.version) < 0) {
//                  console.log("plugin " + name + " requires version " + this.versionToString(plugin.minVersion));
//                  return null;
//              }
//          }
//          if (argument) {
//              if (!plugin.setOptions) {
//                  console.log("options have been provided but the plugin " + name + "does not support any options");
//                  return null;
//              }
//              try {
//                  plugin.setOptions(argument);
//              }
//              catch(e) {
//                  console.log("Error setting options on plugin " + name);
//                  console.log(e.message);
//                  return null;
//              }
//          }
//          return plugin;
//      }
//      return null;
//  };
  }

  ///
  /// Compares the less version required by the plugin
  /// Returns -1, 0, +1
  ///
  // String (as js version) not supported in aVersion for simplicity
  int compareVersion(List<int> aVersion, List<int> bVersion) {
    for (int i = 0; i < aVersion.length; i++) {
      if (aVersion[i] != bVersion[i])
          return (aVersion[i] > bVersion[i]) ? -1 : 1;
    }
    return 0;

//3.0.0 20160713
// AbstractPluginLoader.prototype.compareVersion = function(aVersion, bVersion) {
//     if (typeof aVersion === "string") {
//         aVersion = aVersion.match(/^(\d+)\.?(\d+)?\.?(\d+)?/);
//         aVersion.shift();
//     }
//     for (var i = 0; i < aVersion.length; i++) {
//         if (aVersion[i] !== bVersion[i]) {
//             return parseInt(aVersion[i]) > parseInt(bVersion[i]) ? -1 : 1;
//         }
//     }
//     return 0;
// };
  }

  ///
  /// Transforms a int version list to String
  ///
  /// Example: [1,2,3] => '1.2.3'
  ///
  String versionToString(List<int> version) => version.join('.');

//2.4.0
//  PluginLoader.prototype.versionToString = function(version) {
//      var versionString = "";
//      for (var i = 0; i < version.length; i++) {
//          versionString += (versionString ? "." : "") + version[i];
//      }
//      return versionString;
//  };

  ///
  void printUsage(List<Plugin> plugins) {
    plugins.forEach((Plugin plugin) {
      plugin.printUsage();
    });

//2.4.0
//  PluginLoader.prototype.printUsage = function(plugins) {
//      for (var i = 0; i < plugins.length; i++) {
//          var plugin = plugins[i];
//          if (plugin.printUsage) {
//              plugin.printUsage();
//          }
//      }
//  };
  }

  /// Load plugins
  void start() {
    if (options.plugins.isNotEmpty) {
      options.pluginManager ??= new PluginManager();
      pluginManager = options.pluginManager
          ..addPlugins(options.plugins);
    }
  }
}
