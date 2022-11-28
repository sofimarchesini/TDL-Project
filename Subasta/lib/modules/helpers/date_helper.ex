defmodule DateHelper do
	use Timex

	def ahora_mas(milisegundos) do
		DateHelper.fecha_mas Date.now, milisegundos
	end

	def fecha_mas(fecha, milisegundos) do
		fecha |> Date.add(Time.to_timestamp(milisegundos, :msecs))
	end

	def cuanto_falta_para(datetime) do
		ahora = Date.now
		(Date.diff ahora, datetime, :secs) * 1000
	end
end
