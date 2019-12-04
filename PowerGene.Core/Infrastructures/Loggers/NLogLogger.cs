using Caliburn.Micro;
using NLog;
using System;

namespace PowerGene.Core.Infrastructures.Loggers
{
    /// <summary>
    /// Implementace knihovny nLog
    /// </summary>
    public class NLogLogger : ILogger, ILog
    {
        private readonly Logger _logger;

        public NLogLogger()
        {
            _logger = NLog.LogManager.GetLogger("PowerGene");
        }

        public void Debug(string message)
        {
            _logger.Debug(message);
        }

        public void Trace(string message)
        {
            _logger.Trace(message);
        }

        public void Info(string message)
        {
            _logger.Info(message);
        }

        public void Warning(string message)
        {
            _logger.Warn(message);
        }

        public void Error(string message)
        {
            _logger.Error(message);
        }

        public void Error(string message, Exception exception)
        {
            _logger.Error(exception, message);
        }

        public void Fatal(string message)
        {
            _logger.Fatal(message);
        }

        public void Fatal(string message, Exception exception)
        {
            _logger.Fatal(exception, message);
        }

        public void Info(string format, params object[] args)
        {
            _logger.Info(format, args);
        }

        public void Warn(string format, params object[] args)
        {
            _logger.Warn(format, args);
        }

        public void Error(Exception exception)
        {
            _logger.Error(exception);
        }
    }
}
