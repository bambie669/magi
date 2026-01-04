# Integrare Cypress cu Magi QA

Acest ghid explică cum să integrezi testele Cypress cu Magi QA pentru a sincroniza automat rezultatele testelor.

## Cum funcționează

1. Definești test case-uri în Magi QA cu un **Cypress ID** unic (ex: `TC-001`)
2. În testele Cypress, folosești același ID în titlul testului
3. După `cypress run`, rezultatele sunt trimise automat la Magi QA
4. Statusurile test case-urilor se actualizează în TestRun

## Setup

### 1. Generează un API Token

```bash
cd /path/to/magi
rails console
```

```ruby
user = User.find_by(email: 'your@email.com')
token = ApiToken.create!(user: user, name: 'Cypress CI')
puts token.token  # Salvează acest token!
```

### 2. Copiază fișierele în proiectul Cypress

```bash
cp magi-reporter.js /path/to/cypress/project/
```

### 3. Configurează cypress.config.js

```javascript
const { defineConfig } = require('cypress');
const magiReporter = require('./magi-reporter');

module.exports = defineConfig({
  e2e: {
    setupNodeEvents(on, config) {
      magiReporter(on, config);
      return config;
    }
  },
  env: {
    MAGI_API_URL: 'http://localhost:2507',
    MAGI_API_TOKEN: 'your_token_here',
    MAGI_TEST_RUN_ID: '123'
  }
});
```

### 4. Adaugă Cypress ID în titlurile testelor

```javascript
describe('Login', () => {
  it('TC-001: should login successfully', () => {
    // test code
  });

  it('TC-002: should show error for invalid password', () => {
    // test code
  });
});
```

Formate acceptate pentru ID:
- `TC-001: description`
- `TC-001 - description`
- `[TC-001] description`
- `MAGI-001: description`

### 5. Creează TestCase-uri în Magi QA

În Magi QA, creează test case-uri cu câmpul **Cypress ID** completat:
- Test Case 1: Cypress ID = `TC-001`
- Test Case 2: Cypress ID = `TC-002`

### 6. Creează un TestRun și adaugă test case-urile

1. Mergi la proiect → Test Runs → New Test Run
2. Adaugă test case-urile care au Cypress ID
3. Notează ID-ul TestRun-ului (din URL: `/test_runs/123`)

### 7. Rulează testele

```bash
# Cu variabile de mediu
MAGI_TEST_RUN_ID=123 cypress run

# Sau cu parametri
cypress run --env MAGI_TEST_RUN_ID=123
```

## Utilizare în CI/CD

### GitHub Actions

```yaml
name: E2E Tests

on: [push]

jobs:
  cypress:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Cypress run
        uses: cypress-io/github-action@v6
        env:
          MAGI_API_URL: ${{ secrets.MAGI_API_URL }}
          MAGI_API_TOKEN: ${{ secrets.MAGI_API_TOKEN }}
          MAGI_TEST_RUN_ID: ${{ github.run_id }}
```

### GitLab CI

```yaml
e2e_tests:
  image: cypress/browsers:latest
  script:
    - npm ci
    - npx cypress run
  variables:
    MAGI_API_URL: $MAGI_API_URL
    MAGI_API_TOKEN: $MAGI_API_TOKEN
    MAGI_TEST_RUN_ID: $CI_PIPELINE_ID
```

## Creare automată a TestRun-ului (opțional)

Pentru a crea automat un TestRun înainte de rularea testelor, poți extinde API-ul sau folosi un script:

```bash
# Creează TestRun și obține ID-ul
TEST_RUN_ID=$(curl -s -X POST "$MAGI_API_URL/api/v1/test_runs" \
  -H "Authorization: Bearer $MAGI_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name": "CI Run #123", "project_id": 1}' \
  | jq -r '.id')

# Rulează Cypress cu noul TestRun
MAGI_TEST_RUN_ID=$TEST_RUN_ID cypress run
```

> Notă: Endpoint-ul pentru creare TestRun nu este încă implementat. Poți să-l adaugi dacă ai nevoie.

## Troubleshooting

### "TestCase with cypress_id 'TC-XXX' not found"

- Verifică că ai creat TestCase-ul în Magi cu Cypress ID-ul corect
- Cypress ID-urile sunt case-insensitive (`tc-001` = `TC-001`)

### "TestCase 'TC-XXX' is not part of this test run"

- Adaugă TestCase-ul în TestRun-ul respectiv din Magi UI

### "Unauthorized - Invalid or expired token"

- Verifică că token-ul este corect
- Generează un token nou dacă a expirat

## API Reference

### POST /api/v1/test_runs/:test_run_id/cypress_results

**Headers:**
```
Authorization: Bearer YOUR_TOKEN
Content-Type: application/json
```

**Body:**
```json
{
  "results": [
    {
      "cypress_id": "TC-001",
      "status": "passed",
      "duration_ms": 1234,
      "error_message": null
    },
    {
      "cypress_id": "TC-002",
      "status": "failed",
      "duration_ms": 5678,
      "error_message": "Expected 'foo' to equal 'bar'"
    }
  ]
}
```

**Response:**
```json
{
  "message": "Results processed successfully",
  "test_run_id": 123,
  "summary": {
    "total": 2,
    "updated": 2,
    "not_found": 0,
    "errors": []
  }
}
```

**Statusuri acceptate:**
| Cypress | Magi |
|---------|------|
| passed | passed |
| failed | failed |
| pending | blocked |
| skipped | blocked |
