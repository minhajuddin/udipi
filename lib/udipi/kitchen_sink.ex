defmodule Udipi.KitchenSink do
  require Logger

  def start_link(opts) do
    port = opts[:port] || 4242
    worker_count = opts[:worker_count] || 10
    {:ok, spawn_link(__MODULE__, :init, [port, worker_count])}
  end

  # TODO: make this parallel
  def init(port, _worker_count) do
    {:ok, listener} = :gen_udp.open(port, [:binary, {:active, false}])

    recv_loop(listener)
  end

  defp recv_loop(listener) do
    case :gen_udp.recv(listener, 0, 1) do
      {:ok, {ip, port, data}} ->
        Logger.info(log_code: "udp.recv", ip: ip, port: port, data: data)
        resp = handle_data(ip, port, data)
        :gen_udp.send(listener, ip, port, [resp, ?\n])
        recv_loop(listener)

      {:error, :timeout} ->
        recv_loop(listener)

      {:error, :closed} ->
        {:ok, :closed}
    end
  end

  defp handle_data(_ip, _port, "help" <> _) do
    """
    Available commands:
      help: Shows this help message.
      date: Returns the current utc datetime as an iso8601 formatted string.
      hello: Returns a hello message with the ip and port info.
      echo <message>: Returns the message back to the sender.
    """
  end

  defp handle_data(_ip, _port, "echo " <> data) do
    data
  end

  defp handle_data(ip, port, "hello" <> _) do
    ["Hello ", :inet.ntoa(ip), ":", to_string(port), "!"]
  end

  defp handle_data(_ip, _port, "date" <> _) do
    DateTime.utc_now() |> DateTime.to_iso8601()
  end

  defp handle_data(ip, port, command) do
    Logger.error(error_code: "udp.recv", ip: ip, port: port, data: command)
    "command not found"
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :temporary,
      shutdown: 500
    }
  end
end
