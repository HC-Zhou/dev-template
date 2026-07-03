type Health = {
  status: string
  service: string
  environment: string
}

async function getHealth(): Promise<Health | null> {
  const baseUrl = process.env.NEXT_PUBLIC_API_BASE_URL ?? 'http://localhost:5001'

  try {
    const response = await fetch(`${baseUrl}/health`, { cache: 'no-store' })
    if (!response.ok) return null
    return response.json()
  } catch {
    return null
  }
}

export default async function Home() {
  const health = await getHealth()

  return (
    <main className="shell">
      <section className="hero">
        <div>
          <p className="eyebrow">Fullstack starter</p>
          <h1>Python 3.12 API + Next.js web</h1>
          <p className="summary">
            A compact project skeleton with devcontainer, Docker middleware, separate app
            boundaries, and root-level commands.
          </p>
        </div>
        <div className="status" aria-label="API status">
          <span className={health ? 'dot ok' : 'dot down'} />
          <div>
            <strong>{health ? health.status : 'offline'}</strong>
            <p>{health ? `${health.service} / ${health.environment}` : 'API is not reachable'}</p>
          </div>
        </div>
      </section>
      <section className="grid">
        <article>
          <h2>API</h2>
          <p>FastAPI app in <code>api/</code>, managed by uv.</p>
        </article>
        <article>
          <h2>Web</h2>
          <p>Next.js app in <code>web/</code>, managed by pnpm.</p>
        </article>
        <article>
          <h2>Dev</h2>
          <p>Run <code>make dev-setup</code>, then <code>make dev</code>.</p>
        </article>
      </section>
    </main>
  )
}

