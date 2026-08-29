# ace-config

Mounted read-only into the `ace` container. Drop your own artifacts in here
before `scripts/start.sh` (or restart the `ace` service after adding files).

- `jdbc-drivers/` — JDBC driver jars for the databases your flows connect to.
  IBM/Oracle license terms don't allow these images to ship the drivers, so
  you need to fetch them yourself:
  - Db2: `db2jcc4.jar` (+ `db2jcc_license_cu.jar`), downloadable free from IBM
    (same driver works for db2-orders, db2-customer, and the db2-mainframe
    stand-in).
  - Oracle: `ojdbc11.jar` (or matching version) from Oracle's JDBC driver
    downloads page — requires accepting Oracle's OTN license.
- `policyxml/` — MQEndpoint / JDBCProvider / ODBC policy overrides for the
  integration server (e.g. pointing a policy at `mq:1414`, `db2-orders:50000`,
  `oracle:1521`, etc. — use the in-network hostnames from docker-compose.yml,
  not the host-mapped ports).
- `keystore/` — TLS keystore/certs if you want the ACE web UI or MQ channels
  running over TLS instead of the defaults.

None of this is auto-deployed as message flows — this stack only provides the
runtime. Deploy your BAR files via the ACE web UI (https://localhost:7843),
the ACE Toolkit, or the IBM ACE VS Code extension, pointed at this running
integration server.
