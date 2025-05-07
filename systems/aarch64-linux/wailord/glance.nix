{
  server = {
    host = "localhost";
    port = 8080;
  };
  # Refresh every 5 minutes
  branding = {
    logo-url = "https://msfjarvis.dev/favicon.ico";
    favicon-url = "https://msfjarvis.dev/favicon.ico";
    custom-footer = "<script>if (pageData.slug === 'home')setTimeout(() => location.reload(), 60 * 1000 * 5);</script>";
  };
  theme = {
    background-color = "240 21 15";
    contrast-multiplier = 1.2;
    primary-color = "217 92 83";
    positive-color = "115 54 76";
    negative-color = "347 70 65";
  };
  pages = [
    {
      name = "Home";
      columns = [
        {
          size = "full";
          widgets = [
            {
              type = "lobsters";
              sort-by = "hot";
            }
            {
              type = "group";
              widgets = [
                {
                  type = "reddit";
                  subreddit = "hermitcraft";
                  style = "vertical-list";
                  show-thumbnails = true;
                  sort-by = "top";
                  top-period = "day";
                }
                {
                  type = "reddit";
                  subreddit = "hermitcraftmemes";
                  style = "vertical-list";
                  show-thumbnails = true;
                  sort-by = "top";
                  top-period = "week";
                }
              ];
            }
            {
              type = "videos";
              cache = "15m";
              channels = [
                "UClu2e7S8atp6tG2galK9hgg"
                "UC9lJXqw4QZw-HWaZH6sN-xw"
                "UC4O9HKe9Jt5yAhKuNv3LXpQ"
                "UCFKDEp9si4RmHFWJW1vYsMA"
                "UCuQYHhF6on6EXXO-_i_ClHQ"
                "UCUBsjvdHcwZd3ztdY1Zadcw"
                "UCR9Gcq0CMm6YgTzsDxAxjOQ"
                "UCuMJPFqazQI4SofSFEd-5zA"
                "UCrEtZMErQXaSYy_JDGoU5Qw"
                "UCcJgOennb0II4a_qi9OMkRA"
                "UChFur_NwVSbUozOcF_F2kMg"
                "UC1GJ5aeqpEWklMBQ3oXrPQQ"
                "UCDpdtiUfcdUCzokpRWORRqA"
                "UCodkNmk9oWRTIYZdr_HuSlg"
                "UCYdXHOv7srjm-ZsNsTcwbBw"
                "UC4qdHN4zHhd4VvNy3zNgXPA"
                "UC4YUKOBld2PoOLzk0YZ80lw"
                "UCU9pX8hKcrx06XfOB-VQLdw"
                "UCPK5G4jeoVEbUp5crKJl6CQ"
                "UCjI5qxhtyv3srhWr60HemRw"
              ];
            }
          ];
        }
        {
          size = "small";
          widgets = [
            {
              type = "weather";
              location = "New Delhi, India";
            }
            {
              type = "releases";
              cache = "15m";
              repositories = [
                "thunderbird/thunderbird-android"
                "UweTrottmann/SeriesGuide"
                "JetBrains/Kotlin"
                "Kotlin/kotlinx.serialization"
                "Kotlin/kotlinx.coroutines"
                "square/anvil"
                "tailscale/tailscale"
              ];
            }
            {
              type = "clock";
              hour-format = "12h";
              timezones = [
                {
                  timezone = "Asia/Tokyo";
                  label = "JST";
                }
                {
                  timezone = "Europe/London";
                  label = "UTC";
                }
                {
                  timezone = "America/Los_Angeles";
                  label = "Rot sellers";
                }
              ];
            }
          ];
        }
        {
          size = "small";
          widgets = [
            { type = "calendar"; }
            {
              type = "twitch-channels";
              cache = "1m";
              collapse-after = 10;
              channels = [
                "atrioc"
                "couriway"
                "feinberg"
                "geega"
                "kqsii"
                "laynalazar"
                "mintcastella"
                "projektmelody"
              ];
            }
          ];
        }
      ];
    }
    {
      name = "Services";
      columns = [
        {
          size = "full";
          widgets = [
            {
              type = "monitor";
              cache = "1m";
              title = "Services";
              sites = [
                {
                  title = "Attic cache";
                  url = "https://nix-cache.tiger-shark.ts.net";
                  icon = "si:dask";
                }
                {
                  title = "Git mirror";
                  url = "https://git.msfjarvis.dev";
                  icon = "si:gitea";
                }
                {
                  title = "Grafana";
                  url = "https://grafana.tiger-shark.ts.net";
                  icon = "si:grafana";
                  alt-status-codes = [ 401 ];
                }
                {
                  title = "Private file share";
                  url = "https://wailord.tiger-shark.ts.net";
                  icon = "si:files";
                }
                {
                  title = "Public file share";
                  url = "https://til.msfjarvis.dev";
                  icon = "si:files";
                }
                {
                  title = "Prometheus (matara)";
                  url = "https://prom-matara.tiger-shark.ts.net";
                  icon = "si:prometheus";
                }
                {
                  title = "Prometheus (melody)";
                  url = "https://prom-melody.tiger-shark.ts.net";
                  icon = "si:prometheus";
                }
                {
                  title = "Prometheus (wailord)";
                  url = "https://prom-wailord.tiger-shark.ts.net";
                  icon = "si:prometheus";
                }
                {
                  title = "QBittorrent";
                  url = "https://matara.tiger-shark.ts.net";
                  icon = "si:qbittorrent";
                }
                {
                  title = "RSS reader";
                  url = "https://read.msfjarvis.dev";
                  icon = "si:rss";
                }
                {
                  title = "Vaultwarden";
                  url = "https://vault.msfjarvis.dev";
                  icon = "si:vaultwarden";
                }
              ];
            }
          ];
        }
      ];
    }
  ];
}
