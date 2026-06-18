// ramp.js
import http from "k6/http";
import { check, sleep } from "k6";

function uuidv4() {
  return "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace(/[xy]/g, function (c) {
    const r = (Math.random() * 16) | 0;
    const v = c === "x" ? r : (r & 0x3) | 0x8;
    return v.toString(16);
  });
}

const SEND_MONEY_MUTATION = `
  mutation SendMoney(
    $amount: Float!,
    $from: Int!,
    $to: Int!,
    $fromCurrencyId: Int!,
    $toCurrencyId: Int!,
    $idempotencyKey: String!
  ) {
    sendMoney(
      amount: $amount,
      from: $from,
      to: $to,
      fromCurrencyId: $fromCurrencyId,
      toCurrencyId: $toCurrencyId,
      idempotencyKey: $idempotencyKey
    ) {
      amount
      currency {
        symbol
      }
    }
  }
`;

export const options = {
  stages: [
    { duration: "30s", target: 5 },
    { duration: "60s", target: 5 },
    { duration: "30s", target: 20 },
    { duration: "60s", target: 20 },
    { duration: "30s", target: 50 },
    { duration: "60s", target: 50 },
    { duration: "30s", target: 100 },
    { duration: "60s", target: 100 },
    { duration: "30s", target: 0 },
  ],
};

export default function () {
  const payload = JSON.stringify({
    query: SEND_MONEY_MUTATION,
    variables: {
      amount: 10,
      from: 1,
      to: 2,
      fromCurrencyId: 1,
      toCurrencyId: 2,
      idempotencyKey: uuidv4(),
    },
  });

  const res = http.post("http://localhost:4000/api/graphql", payload, {
    headers: { "Content-Type": "application/json" },
  });

  const httpOk = check(res, { "http 200": (r) => r.status === 200 });

  if (httpOk) {
    const body = res.json();
    check(
      body,
      { "no graphql errors": (b) => !b.errors || b.errors.length === 0 },
      { type: "graphql" },
    );
  }

  sleep(0.1);
}
