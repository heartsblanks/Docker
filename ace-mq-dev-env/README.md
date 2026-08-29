# ACE / MQ / Db2 / Oracle developer test environment

A local Docker/Podman stack for developers to test IBM App Connect Enterprise
(ACE) message flows against real backing services, without touching shared
infra.

## What's in the stack

| Service         | Role                                            | Host port(s)       |
|-----------------|--------------------------------------------------|---------------------|
| `ace`           | IBM ACE integration node, one integration server | 7600, 7800, 7843    |
| `mq`            | IBM MQ 9.5 queue manager                          | 1414, 9443          |
| `db2-orders`    | Db2 application database #1                      | 50000               |
| `db2-customer`  | Db2 application database #2                       | 50001               |
| `db2-mainframe` | Db2 LUW container standing in for the mainframe Db2 (z/OS) your flows target | 50002 |
| `oracle`        | Oracle database (via `gvenzl/oracle-free`)        | 1521, 5500          |

All services share a private Docker/Podman network (`ace-dev-net`) and reach
each other by service name (e.g. `ace` talks to Db2 at `db2-orders:50000`,
not via the host-mapped port).

**Scope**: this stack only stands up the runtime. It does not deploy BAR
files — deploy your own message flows against the running integration
server via the ACE web UI, Toolkit, or VS Code extension.

**Note on "mainframe database"**: Db2 for z/OS cannot run inside a
container. `db2-mainframe` is a plain Db2 LUW container used as a local
stand-in so flows can be developed/tested against the same connection
logic (JDBC/ODBC config, SQL dialect quirks aside) they'd use against the
real mainframe Db2. If your org has an actual mainframe emulator or Db2
Connect gateway you need instead, swap that service in — everything else
in the compose file is unaffected.

## Prerequisites

1. **Docker** (with Compose v2) *or* **Podman** (4.5+, with `podman compose`
   or `podman-compose` installed).
2. Accept the license terms for each product before pulling:
   - IBM MQ developer/trial edition
   - IBM ACE developer/trial edition
   - IBM Db2 developer/trial edition
   - Oracle (via `gvenzl/oracle-free`, MIT-licensed community image — no
     Oracle Container Registry login needed, but confirm this still suits
     your organization's policy)
3. **Verify image tags before first run.** IBM/Oracle rotate these
   frequently. Check the current tags at:
   - https://hub.docker.com/r/ibm-messaging/mq (or `icr.io/ibm-messaging/mq`)
   - https://hub.docker.com/r/ibm-messaging/ace (or `icr.io/appconnect/ace`)
   - https://hub.docker.com/r/ibm-db2/db2 (or `icr.io/db2_community/db2`)
   - https://hub.docker.com/r/gvenzl/oracle-free

   Update `MQ_TAG` / `ACE_TAG` / `DB2_TAG` / `ORACLE_TAG` in `.env`
   accordingly — the values in `.env.example` are a known-good starting
   point, not a guarantee.
4. Disk/RAM headroom: Db2 x3 + Oracle + MQ + ACE is heavy. 16GB+ RAM and
   ~20GB free disk recommended for a comfortable dev box.

### Podman-specific note

Db2's image needs `privileged: true`. On rootless Podman this can be
restrictive — if `db2-orders`/`db2-customer`/`db2-mainframe` fail to start,
either:
- run Podman rootful (`sudo podman ...` / a rootful `podman machine`), or
- on macOS/Windows Podman Desktop, the default machine VM runs rootful
  internally, so this is usually a non-issue.

## Usage

```bash
cd ace-mq-dev-env
cp .env.example .env
# edit .env: set real passwords, confirm/update image tags

./scripts/start.sh      # bring everything up
./scripts/status.sh     # check container/health state
./scripts/stop.sh       # stop, keep data
./scripts/reset.sh      # stop AND wipe all data volumes (asks for confirmation)
```

Each script auto-detects `docker compose`, `podman compose`, or
`podman-compose`, whichever is available — the same `docker-compose.yml`
drives all three.

First boot is slow: Db2 does a one-time instance/database creation
(several minutes each), and Oracle does likewise. Use `scripts/status.sh`
or `docker/podman logs -f <container>` to watch progress instead of
assuming a hang.

## Connecting ACE to the databases/queue manager

Add JDBC drivers, policy XML, and keystore material under `ace-config/`
(read-only mounted into the `ace` container) — see
`ace-config/README.md` for exactly what's needed for Db2/Oracle/MQ. Point
your policies at the in-network hostnames (`mq`, `db2-orders`,
`db2-customer`, `db2-mainframe`, `oracle`), not the host-mapped ports,
since ACE talks to these over `ace-dev-net` directly.

## Cleaning up

`scripts/stop.sh` leaves all data intact for next time. Use
`scripts/reset.sh` when you want a genuinely clean slate (e.g. Db2 got into
a bad state, or you're switching image tags/versions).
