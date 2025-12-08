document.addEventListener('DOMContentLoaded', () => {
    const keywordInput = document.getElementById('keyword');
    const serviceInput = document.getElementById('service');
    const numCharsInput = document.getElementById('numChars');
    const iterationsInput = document.getElementById('iterations');
    const algorithmSelect = document.getElementById('algorithm');
    const generateBtn = document.getElementById('generateBtn');
    const resultTextarea = document.getElementById('result');

    generateBtn.addEventListener('click', generatePassword);

    function generatePassword() {
        const keyword = keywordInput.value;
        const service = serviceInput.value;
        let numChars = parseInt(numCharsInput.value);
        let iterations = parseInt(iterationsInput.value);
        const algorithm = algorithmSelect.value;

        // Validação básica
        if (!keyword) {
            alert('Por favor, insira uma palavra-chave.');
            return;
        }

        // Aplicar defaults
        if (isNaN(iterations) || iterations < 1) {
            iterations = 1;
            iterationsInput.value = 1; // Atualiza o campo se o usuário deixou inválido
        }
        // numChars pode ser NaN se não for informado, o que é tratado como "hash completo"

        let currentHash = keyword;

        if (service) {
            currentHash = `${currentHash}:${service}`;
        }

        if (algorithm === 'MD5') {
            console.warn('MD5 não é recomendado; prefira SHA256 ou SHA512.');
        }

        for (let i = 0; i < iterations; i++) {
            let hashObject;
            switch (algorithm) {
                case 'MD5':
                    hashObject = CryptoJS.MD5(currentHash);
                    break;
                case 'SHA256':
                    hashObject = CryptoJS.SHA256(currentHash);
                    break;
                case 'SHA512':
                    hashObject = CryptoJS.SHA512(currentHash);
                    break;
                default:
                    alert('Algoritmo inválido. Use MD5, SHA256 ou SHA512.');
                    return;
            }
            currentHash = hashObject.toString(CryptoJS.enc.Hex);
        }

        // Cortar o resultado final APENAS se numChars foi especificado e é um número válido
        let finalResult = currentHash;
        if (!isNaN(numChars) && numChars > 0) {
            finalResult = currentHash.substring(0, numChars);
        }

        resultTextarea.value = finalResult;
    }
});
