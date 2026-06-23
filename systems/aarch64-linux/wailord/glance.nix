{ port, tailnetDomain }:
{
  server = {
    host = "localhost";
    inherit port;
  };
  # Refresh every 30 minutes
  branding = {
    logo-url = "https://msfjarvis.dev/favicon.ico";
    favicon-url = "https://msfjarvis.dev/favicon.ico";
    custom-footer = "<script>if (pageData.slug === 'home')setTimeout(() => location.reload(), 60 * 1000 * 30);</script>";
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
              exclude-tags = [
                "vibecoding"
              ];
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
                # Big A Clips
                "UCdBXOyqr8cDshsp7kcKDAkg"
                # Cheese Sculptor
                "UC9Y5-WWYvn16YPO5XW7Nggg"
                # Daily Geega
                "UCNEl_8oA7qCFd1zgrnjjHtA"
                # Geega
                "UCUERxnZSjCq-G7OfYL7Nukg"
                # H and Mr. H
                "UC4_thIY2puJtQdc0vf8nxhQ"
                # Hologatari
                "UCEBVn6em4yXPL8X_tJHAgBA"
                # Rabbit Hole
                "UCdwths-Q8lcuF7wJwVWsC9g"
              ];
            }
          ];
        }
        {
          size = "small";
          widgets = [
            {
              type = "custom-api";
              title = "Open Tasks";
              cache = "5m";
              url = "https://caldav-api.tiger-shark.ts.net/todo";
              template = ''
                <ul class="list list-gap-14 list-with-separator">
                  {{ range .JSON.Array "" }}
                    {{ if eq (.String "status") "NEEDS-ACTION" }}
                      <li class="size-h3">
                        <a href="{{ .String "url" }}" target="_blank" class="color-primary-if-not-visited">
                          {{ .String "summary" }}
                        </a>
                        <div class="text-color-dimmed size-h5 margin-top-4">
                          {{ if .String "due" }}
                            Due <span {{ .String "due" | parseTime "RFC3339" | toRelativeTime }}></span>
                          {{ else if .String "start" }}
                            Starts <span {{ .String "start" | parseTime "RFC3339" | toRelativeTime }}></span>
                          {{ else }}
                            No date set
                          {{ end }}
                          {{ if .String "recurrence_id" }}
                            • Repeats
                          {{ end }}
                          {{ if .Exists "categories" }}
                            {{ range .Array "categories" }} • {{ .String "" }}{{ end }}
                          {{ end }}
                        </div>
                      </li>
                    {{ end }}
                  {{ end }}
                </ul>
              '';
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
            {
              type = "weather";
              location = "Bengaluru, India";
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
                "tailscale/tailscale"
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
                  title = "Actual Budget";
                  url = "https://money.msfjarvis.dev";
                  icon = "si:actualbudget";
                }
                {
                  title = "Attic cache";
                  url = "https://nix-cache.${tailnetDomain}";
                  icon = "si:dask";
                }
                {
                  title = "Git mirror";
                  url = "https://git.msfjarvis.dev";
                  icon = "si:gitea";
                }
                {
                  title = "Grafana";
                  url = "https://grafana.msfjarvis.dev";
                  icon = "si:grafana";
                }
                {
                  title = "Private file share";
                  url = "https://wailord.${tailnetDomain}";
                  icon = "si:files";
                }
                {
                  title = "Public file share";
                  url = "https://til.msfjarvis.dev";
                  icon = "si:files";
                }
                {
                  title = "Prometheus (matara)";
                  url = "https://prom-matara.${tailnetDomain}";
                  icon = "si:prometheus";
                }
                {
                  title = "Prometheus (melody)";
                  url = "https://prom-melody.${tailnetDomain}";
                  icon = "si:prometheus";
                }
                {
                  title = "Prometheus (wailord)";
                  url = "https://prom-wailord.${tailnetDomain}";
                  icon = "si:prometheus";
                }
                {
                  title = "QBittorrent";
                  url = "https://matara.${tailnetDomain}";
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
            {
              type = "html";
              source = ''<img src="https://msfjarvis.github.io/dotfiles/main.svg" />'';
            }
          ];
        }
      ];
    }
  ];
}
