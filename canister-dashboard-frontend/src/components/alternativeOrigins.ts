class AlternativeOriginsManager {
  async init(): Promise<void> {
    this.renderAlternativeOriginsSection();

    const origins = await this.fetchAlternativeOrigins();
    const originsList = origins.map(origin => `<li>${origin}</li>`).join('');

    this.renderAlternativeOriginsContent(originsList);
  }

  private renderAlternativeOriginsSection(): void {
    const alternativeOriginsSection = document.getElementById(
      'alternative-origins-section'
    );

    alternativeOriginsSection!.innerHTML = `
            <h3>Alternative Origins</h3>
            <div id="alternative-origins-content">Loading...</div>
        `;
  }

  private renderAlternativeOriginsContent(originsList: string): void {
    const alternativeOriginsContent = document.getElementById(
      'alternative-origins-content'
    );

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
