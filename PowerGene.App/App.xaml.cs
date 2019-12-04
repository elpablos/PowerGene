using SimpleInjector;
using System;
using System.Security.Principal;
using System.Threading;
using System.Windows;

namespace PowerGene.App
{
    /// <summary>
    /// Interaction logic for App.xaml
    /// </summary>
    public partial class App : Application
    {
        public Container Container { get; set; }

        public App()
        {
            InitializeComponent();
            this.DispatcherUnhandledException += App_DispatcherUnhandledException;
        }

        private void App_DispatcherUnhandledException(object sender, System.Windows.Threading.DispatcherUnhandledExceptionEventArgs e)
        {
            if (e.Exception != null && e.Exception.InnerException != null)
            {
                // zobrazim hlasku
                var dialogResult = MessageBox.Show(e.Exception.InnerException.Message,
                    "Upozornění",
                    MessageBoxButton.OK,
                    MessageBoxImage.Warning);


                // osetrim
                e.Handled = true;
            }
        }

        protected override void OnStartup(StartupEventArgs e)
        {
            // vychozi nastaveni prihlaseni
            Thread.CurrentThread.Name = "PowerGene";
            AppDomain.CurrentDomain.SetPrincipalPolicy(PrincipalPolicy.UnauthenticatedPrincipal);
            //IPrincipal principal = new FormPrincipal(new FormIdentity());
            //Thread.CurrentPrincipal = principal;
            //AppDomain.CurrentDomain.SetThreadPrincipal(principal);

            base.OnStartup(e);
        }
    }
}
