using demoapp.Models;
using Microsoft.AspNetCore.Hosting.Server;
using Microsoft.AspNetCore.Mvc;
using System.Diagnostics;
using  demoapp.Helpers;

namespace demoapp.Controllers
{
    public class HomeController : Controller
    {
        private readonly ILogger<HomeController> _logger;

        public HomeController(ILogger<HomeController> logger)
        {
            _logger = logger;
        }

        private FilesViewModel GetFilesViewModel()
        {
            var filesViewModel = new FilesViewModel();
            filesViewModel.Files = new string[] { "error getting the files"};
            filesViewModel.EnvironmentVariablesNames = new string[] { "error getting env variables"};
            filesViewModel.EnvironmentVariablesValues = new string[] { "error getting env variables"};
            try
            {
                filesViewModel.Files = FilesExtension.TryGetFiles("/mnt/demoappfiles");
                filesViewModel.Secrets =  FilesExtension.TryGetFiles("/mnt/secrets");
                filesViewModel.EnvironmentVariablesNames = Environment.GetEnvironmentVariables().Keys.Cast<string>().ToArray();
                filesViewModel.EnvironmentVariablesValues = Environment.GetEnvironmentVariables().Values.Cast<string>().ToArray();

                Console.WriteLine("Files found: {0}", filesViewModel.Files.Length);
                Console.WriteLine("Files found: {0}", filesViewModel.Secrets.Length);
                Console.WriteLine("Environment Variables found: {0}", filesViewModel.EnvironmentVariablesNames.Length);
            }
            catch (Exception ex)
            {
                Debug.WriteLine(ex);
                throw;
            }

            return filesViewModel;
        }

        public IActionResult Index()
        {
            var filesViewModel = GetFilesViewModel();
            return View(filesViewModel);
        }

        public IActionResult Privacy()
        {

            return View();
        }

        public IActionResult EnvironmentVariables()
        {
            var filesViewModel = GetFilesViewModel();
            return View(filesViewModel);
        }


        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }


        public IActionResult CreateFiles()
        {
            for (int i = 0; i < 10; i++)
            {
                CreateSingleFile($"/mnt/demoappfiles/file{i}.txt");
            }

            return RedirectToAction("Index");
        }

        public IActionResult DeleteFiles()
        {
            foreach(string file in Directory.GetFiles("/mnt/demoappfiles"))
            {
                System.IO.File.Delete(file);
            }

            return RedirectToAction("Index");

        }
        //Create a method that creates a file in an specific path
        private void CreateSingleFile(string fullFilePath)
        {
            //Check if the file already exists. If it does, delete it. 
            if (System.IO.File.Exists(fullFilePath))
            {
                System.IO.File.Delete(fullFilePath);
            }

            //Create the file.
            using (StreamWriter outputFile = new StreamWriter(fullFilePath))
            {
                var content = "New file created: ${fullFilePath}";
                outputFile.WriteLine(content);
            }
        }
    }
}