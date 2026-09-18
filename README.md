# Survey App Workshop

You are building the backend for a survey app: an API that stores questions,
collects answers, and reports results. The infrastructure is already written.
Your job is the CRUD endpoints in `backend/survey.py`.

Everything runs on your laptop in containers. No AWS account, no credentials,
and no Terraform are needed to take part. Deploying to AWS is an optional
extra at the end, in `infra/README.md`.

## Before the workshop

You need **Git** and **Docker**. Pick your operating system below.

Do this before the session, not during it. Docker installs are the one thing
we cannot fix quickly in a room, and on Windows it requires a restart.

### Windows

Docker Desktop on Windows runs on WSL 2, so install that first. Open
PowerShell **as Administrator** and run:

```powershell
wsl --install
```

**Restart your computer.** This step is not optional and cannot be skipped on
workshop day.

Then, in a normal PowerShell window:

```powershell
winget install --id Git.Git --exact
winget install --id Docker.DockerDesktop --exact
```

Open Docker Desktop once and wait for it to finish starting.

### macOS

```bash
brew install --cask docker-desktop
```

Use `--cask`. Plain `brew install docker` gives you the CLI with no engine
behind it, and every command then fails with `Cannot connect to the Docker
daemon`. Open Docker Desktop once after installing.

No Homebrew? Download Docker Desktop from
<https://www.docker.com/products/docker-desktop/> and pick the build matching
your chip, Apple Silicon or Intel.

### Linux

Install Docker Engine and the Compose plugin from your package manager, or run
`./setup/install-unix.sh`.

### Everyone: check it worked

```bash
docker compose version
```

A version number means you are ready. `Cannot connect to the Docker daemon`
means Docker Desktop is installed but not running, so open it and wait.

The scripts in `setup/` do all of the above for you, plus the tools for the
optional AWS track. See `setup/README.md`.

## Start the app

Three commands, from any folder:

```bash
git clone -b part-2 https://github.com/NSBE-TechWorkshops/Survey-Webapp.git
cd Survey-Webapp
docker compose up --build
```

The first build takes a few minutes. After that it is seconds.

This starts two containers: the FastAPI backend on port `8000`, and a local
DynamoDB on port `8001`. The table is created automatically on startup.

Stop everything with `Ctrl+C`. The local database is in memory, so data is
cleared each time you stop. That is on purpose, it gives you a clean slate.

If you cloned during the first workshop, run `git pull` instead of cloning.

## Check your setup

Open <http://localhost:8000/docs>. You should see the interactive API page.

Then run the health check, which writes a row, reads it back, and deletes it.

macOS and Linux:

```bash
curl http://localhost:8000/health
```

Windows PowerShell:

```powershell
Invoke-RestMethod http://localhost:8000/health
```

Expected:

```json
{"ok": true, "table": "survey-responses", "wrote": "healthcheck_...", "read_back": {...}}
```

`"ok": true` means your setup is finished and the database is reachable. If
you get that, you are ready to write code.

## What you are implementing

Open `backend/survey.py`. Six endpoints currently return
`501 Not Implemented`. That is expected, they are yours to write.

| Endpoint | Method | What it should do |
| --- | --- | --- |
| `/create-questions` | POST | Save a new question, return it with its generated id |
| `/get-questions` | GET | Return every question |
| `/update-question/{response_id}` | PUT | Change the text of one question |
| `/delete-questions/{response_id}` | DELETE | Delete one question by id |
| `/answer` | POST | Save an answer linked to a question |
| `/results/{question_id}` | GET | Return every answer for one question |

Everything lives in one table. Each row needs a `response_id` (the partition
key) and a `type` so the two kinds of row can be told apart:

```python
question row -> {"response_id": "question_ab12...", "type": "question",
                 "question": "...", "created_time": ...}

answer row   -> {"response_id": "answer_cd34...", "type": "answer",
                 "question_id": "question_ab12...", "name": "...",
                 "answer": "...", "created_time": ...}
```

Work in the order above. Each endpoint has a docstring telling you which
boto3 call to reach for. The methods you need are `table.put_item`,
`table.get_item`, `table.scan`, `table.update_item`, and `table.delete_item`.

DynamoDB has no auto-increment and no foreign keys. You generate ids
yourself, and nothing stops an answer pointing at a question that does not
exist.

## Test as you go

The server reloads when you save, so you do not need to restart anything.

The easiest way, and the same on every machine, is the `Try it out` buttons
at <http://localhost:8000/docs>. Use that if you are not sure.

If you prefer the terminal, macOS and Linux:

```bash
# Create a question
curl -X POST http://localhost:8000/create-questions \
  -H "Content-Type: application/json" \
  -d '{"content": "What is your favorite language?"}'

# List questions
curl http://localhost:8000/get-questions

# Answer one (use an id from the call above)
curl -X POST http://localhost:8000/answer \
  -H "Content-Type: application/json" \
  -d '{"question_id": "question_abc123", "name": "Ada", "answer": "Python"}'

# See the results
curl http://localhost:8000/results/question_abc123
```

Windows PowerShell. Do not copy the Bash commands above, PowerShell aliases
`curl` to a different tool and the flags will not work:

```powershell
# Create a question
Invoke-RestMethod -Method Post -Uri http://localhost:8000/create-questions `
  -ContentType "application/json" `
  -Body '{"content": "What is your favorite language?"}'

# List questions
Invoke-RestMethod http://localhost:8000/get-questions

# Answer one (use an id from the call above)
Invoke-RestMethod -Method Post -Uri http://localhost:8000/answer `
  -ContentType "application/json" `
  -Body '{"question_id": "question_abc123", "name": "Ada", "answer": "Python"}'

# See the results
Invoke-RestMethod http://localhost:8000/results/question_abc123
```

## Troubleshooting

**`docker: command not found` or `Cannot connect to the Docker daemon`**
Docker Desktop is not running. Open it and wait for the whale icon to settle.

**`port is already allocated` on 8000**
Something else is using the port. Stop it, or change the left side of
`"8000:8000"` in `docker-compose.yml` to `"8080:8000"` and use port 8080.

**`/health` returns a 500 about endpoint or credentials**
The backend cannot see the database container. Run `docker compose down`
then `docker compose up --build` so both start together.

**Code changes do nothing**
Confirm you are editing `backend/survey.py` inside the folder you cloned, and
watch the `docker compose` output for the reload line.

**macOS: "Docker Not Opened", Apple could not verify it is free of malware**
Click **Done**, not Move to Trash. The app is fine, macOS is just refusing an
unverified or partly written download. Open **System Settings > Privacy &
Security**, scroll to the Security section, and click **Open Anyway** next to
the Docker message. If that button is not there, the download is damaged:

```bash
brew reinstall --cask docker-desktop
open -a Docker
```

As a last resort, clear the quarantine flag and open it:

```bash
sudo xattr -dr com.apple.quarantine /Applications/Docker.app
open -a Docker
```

**macOS: `unknown flag: --build` from `docker compose up --build`**
You have the Docker CLI with no Compose plugin, usually from
`brew install docker` without `--cask`. Run `brew uninstall docker`, then
`brew install --cask docker-desktop`, and open Docker Desktop once.

**Windows: `docker` is not recognized**
Close PowerShell and open a new window so it picks up the updated PATH. If it
still fails, Docker Desktop is not installed, only the CLI.

**Windows: Docker Desktop will not start, or complains about WSL 2**
Run `wsl --install` in an Administrator PowerShell and restart your computer.
If it still fails, virtualization may be disabled in your BIOS or Virtual
Machine Platform may be turned off in Windows Features.

**Everything is broken and time is short**
`docker compose down -v` then `docker compose up --build` gives you a clean
start.

## Running without Docker

Only if Docker will not cooperate on your machine. You need Python 3.12 and
Java 17 or newer.

Download DynamoDB Local from AWS, unpack it, and start it in one terminal:

```bash
# https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DynamoDBLocal.DownloadingAndRunning.html
java -Djava.library.path=./DynamoDBLocal_lib -jar DynamoDBLocal.jar -sharedDb -inMemory -port 8001
```

Then start the backend in a second terminal:

macOS and Linux:

```bash
pip install -r requirements-dev.txt
DYNAMODB_ENDPOINT=http://localhost:8001 ./run.sh
```

Windows PowerShell (`run.sh` is a Bash script, so start Uvicorn directly):

```powershell
pip install -r requirements-dev.txt
$env:DYNAMODB_ENDPOINT = "http://localhost:8001"
cd backend
python -m uvicorn survey:app --port 8000 --reload
```

If this is where you end up, pair with someone whose Docker works instead.
Fighting a local Python install is not what the session is for.

## Optional: deploy it to AWS

Once your endpoints work locally, you can put them on real AWS Lambda and
DynamoDB with Terraform. That track needs an AWS account and credentials, and
it is written up in `infra/README.md`. It is not part of the workshop session,
and it can cost money if you leave the resources running, so destroy them when
you are done.
