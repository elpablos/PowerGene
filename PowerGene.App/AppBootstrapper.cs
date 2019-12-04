using Caliburn.Micro;
using System;
using SimpleInjector;
using System.Collections.Generic;
using System.Reflection;
using System.Windows;
using PowerGene.App.ViewModels.Shells;
using SimpleInjector.Lifestyles;
using System.IO;
using System.Linq;

namespace PowerGene.App
{
    public class AppBootstrapper : BootstrapperBase
    {
        ///   <summary> 
        ///  The global container. 
        ///   </summary> 
        public static readonly Container ContainerInstance = new Container();

        public Scope Scope { get; private set; }

        public AppBootstrapper()
        {
            Initialize();
            ((PowerGene.App.App)this.Application).Container = ContainerInstance;
        }

        protected override void Configure()
        {
            SimpleInjectorContainer.Build(ContainerInstance);
            var logger = ContainerInstance.GetInstance<Core.Infrastructures.Loggers.ILogger>();
            LogManager.GetLog = type => (ILog)logger;
        }

        protected override IEnumerable<object> GetAllInstances(Type service)
        {
            return new[] { GetInstance(service, null) };
        }

        protected override object GetInstance(Type service, string key)
        {
            return ContainerInstance.GetInstance(service);
        }

        protected override void OnStartup(object sender, StartupEventArgs e)
        {
            Scope = ThreadScopedLifestyle.BeginScope(ContainerInstance);
            // ContainerInstance.BeginLifetimeScope();
            DisplayRootViewFor<IShellViewModel>();
        }

        protected override void OnExit(object sender, EventArgs e)
        {
            // Scope
            Scope.Dispose();
            base.OnExit(sender, e);
        }

        protected override IEnumerable<Assembly> SelectAssemblies()
        {
            return SimpleInjectorContainer.SelectAssemblies();
        }

        protected override void BuildUp(object instance)
        {
            var registration = ContainerInstance.GetRegistration(instance.GetType(), true);
            registration.Registration.InitializeInstance(instance);
        }
    }
}
