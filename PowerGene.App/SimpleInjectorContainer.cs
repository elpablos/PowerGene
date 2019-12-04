using Caliburn.Micro;
using PowerGene.App.ViewModels.Dictionaries;
using PowerGene.App.ViewModels.Settings;
using PowerGene.App.ViewModels.Shells;
using PowerGene.Core;
using PowerGene.Core.Common;
using PowerGene.Core.Infrastructures.Loggers;
using SimpleInjector;
using SimpleInjector.Lifestyles;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;

namespace PowerGene.App
{
    /// <summary>
    /// Vychozi nastaveni simple injectoru
    /// </summary>
    public static class SimpleInjectorContainer
    {
        /// <summary>
        /// Tvorba spoju mezi interfaci a instancemi
        /// </summary>
        /// <returns></returns>
        public static void Build(Container container)
        {
            // vychozi lifestyle
            container.Options.DefaultScopedLifestyle = new ThreadScopedLifestyle();

            // basic
            container.Register<IWindowManager, WindowManager>();
            container.Register<IEventAggregator, EventAggregator>(Lifestyle.Singleton);
            container.RegisterSingleton<ILogger, NLogLogger>();

            // viewModel
            container.Register<IShellViewModel, ShellViewModel>();
            container.Register<ISettingViewModel, SettingViewModel>();
            container.Register<IDictionaryViewModel, DictionaryViewModel>();

            // view
            container.Collection.Register<ITabView>(SelectAssemblies());

            // core
            CoreSimpleInjectorContainer.Build(container);

            // verifikace
            container.Verify();
        }

        public static IEnumerable<Assembly> SelectAssemblies()
        {
            var assemblies = new List<Assembly>();
            assemblies.Add(Assembly.GetExecutingAssembly());

            var moduleFolder = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);
            var loadedAssemblies = Directory.GetFiles(moduleFolder,
                "PowerGene.Module.*.dll", SearchOption.AllDirectories)
                .Select(Assembly.LoadFrom).ToList();

            if (loadedAssemblies != null)
            {
                assemblies.AddRange(loadedAssemblies);
            }

            return assemblies;
        }
    }
}
