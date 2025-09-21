export const API = import.meta.env.VITE_EVENTS_API_URL || "/events-api";

export async function apiGet(path) {
  const r = await fetch(`${API}${path}`, { credentials: "include" });
  if (!r.ok) throw new Error(`GET ${path} -> ${r.status}`);
  return r.json();
}

export async function apiJSON(method, path, body) {
  const r = await fetch(`${API}${path}`, {
    method,
    headers: { "Content-Type": "application/json" },
    credentials: "include",
    body: JSON.stringify(body ?? {})
  });
  if (!r.ok) throw new Error(`${method} ${path} -> ${r.status}`);
  return r.json();
}