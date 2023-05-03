using System.Diagnostics;
using System.IO;

namespace demoapp.Helpers
{
    public static class FilesExtension
    {
        public static string[] TryGetFiles(string directoryPath)
        {
            try
            {
                if(!Directory.Exists(directoryPath))
                {
                    return new string[] { $"directory '{directoryPath}' does not exist"};
                }
                return Directory.GetFiles(directoryPath);
            }
            catch (Exception ex)
            {
                Debug.WriteLine(ex);
                throw;
            }
        }
    }
}