class AlternativeOriginsManager {
  async init(): Promise<void> {
    const alternativeOriginsSection = document.getElementById(
      'alternative-origins-section'
    );

    alternativeOriginsSection!.innerHTML = `
            <h3>Alternative Origins</h3>
            <div id="alternative-origins-content">Loading...</div>
        `;

    const alternativeOriginsContent = document.getElementById(
      'alternative-origins-content'
    );

    const origins = await this.fetchAlternativeOrigins();

    const originsList = origins.map(origin => `<li>${origin}</li>`).join('');

    alternativeOriginsContent!.innerHTML = `
                <div class="alternative-origins-info">
                    <ul>
                        ${originsList}
                    </ul>
                </div>
            `;
  }

  private async fetchAlternativeOrigins(): Promise<string[]> {
    const response = await fetch('/.well-known/ii-alternative-origins');
    const data = await response.json();
    return data.alternativeOrigins;
  }
}

export async function initAlternativeOrigins(): Promise<void> {
  const alternativeOriginsManager = new AlternativeOriginsManager();
  await alternativeOriginsManager.init();
}
