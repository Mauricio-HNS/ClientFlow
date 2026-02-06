export default function App() {
  return (
    <div className="page">
      <header className="hero">
        <p className="eyebrow">ClientFlow</p>
        <h1>Dashboard de administracao</h1>
        <p className="subtitle">
          Organize clientes, agenda e performance em um unico lugar.
        </p>
      </header>

      <section className="grid">
        <article className="card">
          <h2>Proximos agendamentos</h2>
          <p>Veja os compromissos das proximas 24 horas.</p>
        </article>
        <article className="card">
          <h2>Clientes ativos</h2>
          <p>Acompanhe quem mais interage com o seu negocio.</p>
        </article>
        <article className="card">
          <h2>Receita projetada</h2>
          <p>Visao rapida de faturamento e tendencia.</p>
        </article>
      </section>
    </div>
  )
}
