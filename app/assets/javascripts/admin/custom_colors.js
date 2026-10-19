// Funcionalidade para paleta de cores personalizada
document.addEventListener('DOMContentLoaded', function() {
  console.log('[custom-colors] DOMContentLoaded');

  // Para cada color picker customizado
  const colorInputs = document.querySelectorAll('.hidden-color-input');
  console.log('[custom-colors] encontrados hidden-color-input:', colorInputs.length);

  colorInputs.forEach(function(input) {
    const name = input.id.replace('skin_color_value_', '');
    const button = document.getElementById('openColorPicker_' + name);
    const preview = document.getElementById('colorPreview_' + name);

    console.log('[custom-colors] setup input:', {
      inputId: input.id,
      name,
      buttonFound: !!button,
      previewFound: !!preview,
      initialValue: input.value
    });

    if (!button || !preview) {
      console.warn('[custom-colors] botão ou preview não encontrados para', name);
      return;
    }

    // Preview inicial
    preview.style.background = input.value;

    button.addEventListener('click', function() {
      console.log('[custom-colors] botão clicado para', name, 'valor atual:', input.value);
      input.click();  // Abre o seletor nativo
    });

    input.addEventListener('input', function() {
      console.log('[custom-colors] input de cor alterado:', {
        name,
        newValue: input.value
      });

      preview.style.background = input.value;

      // Adicionar ou atualizar a opção custom na paleta
      addCustomColorToPalette(name, input.value, input);
    });
  });

  // Atualizar CSS quando uma cor for selecionada (cores já existentes)
  const colorRadios = document.querySelectorAll('.color-pick-option input[type="radio"]');
  console.log('[custom-colors] rádios encontrados inicialmente:', colorRadios.length);

  colorRadios.forEach(function(radio) {
    radio.addEventListener('change', function() {
      if (!radio.checked) return;

      const label = document.querySelector(`label[for="${radio.id}"]`);
      const color = label ? label.style.backgroundColor : null;

      console.log('[custom-colors] rádio alterado:', {
        id: radio.id,
        name: radio.name,
        value: radio.value,
        color
      });

      if (color) {
        document.documentElement.style.setProperty('--main-color', color);
        console.log('[custom-colors] --main-color atualizado para', color);
      } else {
        console.warn('[custom-colors] não foi possível obter a cor do label para', radio.id);
      }
    });
  });

  function addCustomColorToPalette(name, colorValue, inputEl) {
    console.log('[custom-colors] addCustomColorToPalette chamado:', {
      name,
      colorValue
    });

    // tenta achar o container de cores RELACIONADO a esse campo
    const formGroup = inputEl.closest('.form-group');
    let container = null;

    if (formGroup) {
      container = formGroup.querySelector('.color-pick-container');
    }

    // fallback: pega o primeiro da página (não é o ideal, mas ajuda a ver se tá caindo aqui)
    if (!container) {
      console.warn('[custom-colors] container específico não encontrado, tentando .color-pick-container global');
      container = document.querySelector('.color-pick-container');
    }

    if (!container) {
      console.error('[custom-colors] nenhum .color-pick-container encontrado para', name);
      return;
    }

    console.log('[custom-colors] usando container para', name, container);

    // Remover qualquer custom anterior
    const existingCustom = container.querySelector('.custom-color-option');
    if (existingCustom) {
      console.log('[custom-colors] removendo custom-color-option anterior');
      existingCustom.remove();
    }

    // Criar nova opção
    const customDiv = document.createElement('div');
    customDiv.className = 'color-pick-option custom-color-option';

    const radio = document.createElement('input');
    radio.type = 'radio';
    radio.name = name; // MESMO name das outras opções
    radio.value = 'custom_' + Date.now();
    radio.id = 'color-' + radio.value;

    const label = document.createElement('label');
    label.style.backgroundColor = colorValue;
    label.setAttribute('for', radio.id);

    const sub = document.createElement('div');
    sub.className = 'sub-color';

    customDiv.appendChild(radio);
    customDiv.appendChild(label);
    customDiv.appendChild(sub);

    container.appendChild(customDiv);

    console.log('[custom-colors] custom-color-option criada e adicionada:', {
      radioId: radio.id,
      radioName: radio.name,
      radioValue: radio.value,
      colorValue
    });

    // Listener para o novo radio
    radio.addEventListener('change', function() {
      if (!radio.checked) return;

      console.log('[custom-colors] rádio CUSTOM selecionado:', {
        id: radio.id,
        name: radio.name,
        value: radio.value,
        color: colorValue
      });

      document.documentElement.style.setProperty('--main-color', colorValue);
      console.log('[custom-colors] --main-color atualizado (custom) para', colorValue);
    });

    // já marca o custom como selecionado e dispara o change
    radio.checked = true;
    radio.dispatchEvent(new Event('change', { bubbles: true }));

    // === Criar os campos hidden que o Rails espera ===
    injectRailsHiddenFields(name, radio.value, colorValue);
  }

  // ====== 4) Gera campos hidden seguindo a estrutura do Weby ======
  function injectRailsHiddenFields(name, customName, colorValue) {
    console.log('[custom-colors] injectRailsHiddenFields', { name, customName, colorValue });

    // Remove hidden antigos
    document.querySelectorAll(`input[name="${name}_custom"]`).forEach(e => e.remove());
    document.querySelectorAll(`input[name="color_value_${name}"]`).forEach(e => e.remove());

    // 1) Campo com o valor da cor custom (main)
    const mainInput = document.createElement('input');
    mainInput.type = 'hidden';
    mainInput.name = `color_value_${name}`;
    mainInput.value = colorValue;
    document.forms[0].appendChild(mainInput);

    // 2) JSON com as propriedades da cor
    const data = {};
    data[customName] = {
      main: colorValue,
      sub: colorValue,
      group: "custom"
    };

    const customInput = document.createElement('input');
    customInput.type = 'hidden';
    customInput.name = `${name}_custom`;  // <= EXATAMENTE O QUE O CONTROLLER ESPERA
    customInput.value = JSON.stringify(data);
    document.forms[0].appendChild(customInput);

    console.log('[custom-colors] campos adicionados:', {
      mainField: mainInput.name,
      customField: customInput.name,
      payload: data
    });
  }
});
