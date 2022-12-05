server:
	type=server iex --sname server --cookie subastas -S mix phoenix.server
client:
	type=client server=server@localhost iex --sname aldana --cookie subastas -S mix run --eval "ClientServer.start('Aldana', Node.self, self)"
client2:
	type=client server=server@localhost iex --sname ariel --cookie subastas -S mix run --eval "ClientServer.start('Ariel', Node.self, self)"
client3:
	type=client server=server@localhost iex --sname rodri --cookie subastas -S mix run --eval "ClientServer.start('Rodri', Node.self, self)"
failover:
	type=failover server=server@localhost iex --sname failover --cookie subastas -S mix phoenix.server --eval "FailoverProcess.start()"
tests:
	mix test
drop_db:
	mongo iasc_tp_subastas_dev --eval "db.dropDatabase()"