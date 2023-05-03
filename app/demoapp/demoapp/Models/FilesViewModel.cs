namespace demoapp.Models
{
    public class FilesViewModel
    {
        public string[] Files { get; set; }

        public string[] Secrets { get; set; }

        public string[] EnvironmentVariablesNames { get; set; }
        public string[] EnvironmentVariablesValues { get; set; }
    }
}