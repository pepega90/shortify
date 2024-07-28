defmodule ShortenWeb.Live.Index do
  use ShortenWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div class="center-container">
      <div class="bg-white p-8 rounded-lg shadow-lg z-10 max-w-md w-full">
        <h1 class="text-2xl font-bold mb-4 text-center">URL Shortener</h1>
        
        <form id="url-form" class="flex flex-col items-center" phx-submit="shorten">
          <div class="flex w-full mb-2">
            <input
              type="url"
              id="url"
              name="url"
              class="flex-grow p-2 border border-gray-300 rounded-l mt-2"
              placeholder="Enter URL"
            />
            <button
              type="submit"
              class="bg-blue-500 text-white px-4 py-2 rounded-r mt-2 hover:bg-blue-600"
            >
              Shorten URL
            </button>
          </div>
          
          <div id="loading" class={"mt-4 text-center #{if @loading, do: "flex", else: "hidden"}"}>
            <div class="loader mx-auto"></div>
          </div>
        </form>
        
        <div
          id="shortened-url"
          class={"mt-4 text-center #{if @shorten && !@loading, do: "", else: "hidden"}"}
        >
          <p class="text-gray-700">Shortened URL:</p>
          
          <div class="flex justify-center items-center">
            <a
              href={@url |> Map.get(@short_url)}
              id="short-url"
              class="text-blue-500 hover:underline mr-2"
            >
              <%= @short_url %>
            </a>
            
            <button
              id="copy-button"
              class="bg-green-500 text-white px-4 py-2 rounded-full hover:bg-green-600"
            >
              Copy to clipboard
            </button>
          </div>
        </div>
      </div>
    </div>

    <script>
      document.addEventListener('DOMContentLoaded', function () {
      const copyButton = document.getElementById('copy-button');
      const shortUrl = document.getElementById('short-url');

      copyButton.addEventListener('click', function () {
        navigator.clipboard.writeText(shortUrl.textContent).then(function () {
          alert('URL copied to clipboard!');
        }, function (err) {
          console.error('Could not copy text: ', err);
        });
      });
      });
    </script>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(
       url: %{},
       shorten: false,
       short_url: "",
       origin_url: "",
       loading: false
     )}
  end

  @impl true
  def handle_event("shorten", %{"url" => ""}, socket), do: {:noreply, socket}

  def handle_event("shorten", %{"url" => url} = _params, socket) do
    Process.send_after(self(), "generate_url", 2000)
    {:noreply, socket |> assign(origin_url: url, loading: true)}
  end

  @impl true
  def handle_info(
        "generate_url",
        %{assigns: %{url: map_url, origin_url: origin_url}} = socket
      ) do
    short_url_key = "https://pepega.ly/" <> generate_random_string()
    updated_map = map_url |> Map.put(short_url_key, origin_url)

    {:noreply,
     socket
     |> assign(
       url: updated_map,
       shorten: true,
       short_url: short_url_key,
       loading: false
     )}
  end

  defp generate_random_string do
    :crypto.strong_rand_bytes(10)
    |> Base.url_encode64(padding: false)
    |> binary_part(0, 10)
  end
end
