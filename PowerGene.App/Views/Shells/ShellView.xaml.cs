using Fluent;
using PowerGene.App.ViewModels.Shells;
using PowerGene.Core.Events;
using System;
using System.Windows;
using System.Windows.Threading;

namespace PowerGene.App.Views.Shells
{
    /// <summary>
    /// Interaction logic for ShellView.xaml
    /// </summary>
    public partial class ShellView : RibbonWindow
    {
        private DispatcherTimer _timer;

        public IShellViewModel Context { get; private set; }

        public ShellView()
        {
            InitializeComponent();
            txtVersion.Value = $"v{System.Reflection.Assembly.GetExecutingAssembly().GetName().Version.ToString()}";

            Drop += RibbonWindow_Drop;
            AllowDrop = true;

            Loaded += ShellView_Loaded;
            Unloaded += ShellView_Unloaded;
        }

        private void ShellView_Unloaded(object sender, RoutedEventArgs e)
        {
            if (_timer != null)
            {
                _timer.Stop();
                _timer.Tick -= Timer_Tick;
                _timer = null;
            }
        }

        private void ShellView_Loaded(object sender, RoutedEventArgs e)
        {
            Context = DataContext as ViewModels.Shells.IShellViewModel;

            var timer = new System.Windows.Threading.DispatcherTimer();
            timer.Interval = TimeSpan.FromMilliseconds(100);
            timer.Tick += Timer_Tick;
            timer.Start();
            _timer = timer;
        }

        private void Timer_Tick(object sender, System.EventArgs e)
        {
            if (!Context.Model.Logs.IsEmpty)
            {
                if (Context.Model.Logs.TryDequeue(out LogEvent log))
                {
                    Log.AppendText(log.Text + Environment.NewLine);
                    Log.ScrollToEnd();
                }
            }
        }

        private void RibbonWindow_Drop(object sender, System.Windows.DragEventArgs e)
        {
            if (e.Data.GetDataPresent(DataFormats.FileDrop))
            {
                string[] files = (string[])e.Data.GetData(DataFormats.FileDrop);
                if (files.Length > 0)
                {
                    Context.LoadAction(files[0]);
                }

            }
        }

        private void Script_KeyDown(object sender, System.Windows.Input.KeyEventArgs e)
        {
            var txt = sender as System.Windows.Controls.TextBox;
            if (e.Key == System.Windows.Input.Key.Enter)
            {
                Context.RunScript(txt.Text);
                txt.Text = string.Empty;
            }
        }

        private void ShowPowershellButton_Click(object sender, RoutedEventArgs e)
        {
            var btn = sender as System.Windows.Controls.Primitives.ToggleButton;
            LogDock.Visibility = btn.IsChecked == true ? Visibility.Collapsed : Visibility.Visible;
        }

        private void ClearButton_Click(object sender, RoutedEventArgs e)
        {
            Log.Clear();
        }
    }
}
