using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;

namespace WebBanSach
{
    public class RouteConfig
    {
        public static void RegisterRoutes(RouteCollection routes)
        {
            routes.IgnoreRoute("{resource}.axd/{*pathInfo}");
            routes.IgnoreRoute("{folder}/{*pathInfo}", new { folder = "css|js|images|Content|Scripts|fonts|bundles" });
            routes.IgnoreRoute("favicon.ico");
            routes.RouteExistingFiles = true;
            // Keep existing .html bookmarks while serving actual Razor views and layouts.
            routes.MapRoute(
                name: "PortalPages",
                url: "{page}.html",
                defaults: new { controller = "Portal", action = "Page" },
                constraints: new { page = "index|admin|cart|checkout|tracking|book-details|login|register|verify-email" },
                namespaces: new[] { "WebBanSach.Controllers" }
            ).RouteExistingFiles = true;

            routes.MapRoute(
                name: "Api",
                url: "api/{action}/{id}",
                defaults: new { controller = "Api", id = UrlParameter.Optional },
                namespaces: new[] { "WebBanSach.Controllers" }
            );

            routes.MapRoute(
                name: "Default",
                url: "{controller}/{action}/{id}",
                defaults: new { controller = "Home", action = "Index", id = UrlParameter.Optional },
                namespaces: new[] { "WebBanSach.Controllers" }
            );
        }
    }
}
