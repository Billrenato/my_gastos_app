# MyGastos App

**MyGastos** é um aplicativo mobile de controle financeiro pessoal, focado em registrar, categorizar e visualizar gastos de forma eficiente. Desenvolvido em **Flutter** e utilizando **Hive** para armazenamento local de dados, o projeto oferece uma solução rápida e offline para a gestão de despesas recorrentes e diárias.

---

## 💡 Funcionalidades Principais

* **Controle de Gastos:** Registro rápido de despesas com campos para título, valor e data.
* **Categorização:** Gerenciamento de categorias personalizadas (como Alimentação, Transporte, Assinaturas) com cores distintas.
* **Gestão de Recorrência:** Opção para marcar gastos como recorrentes (mensais).
* **Visão Calendário:** Visualização das despesas distribuídas em um calendário.
* **Notificações (Planejado):** Configuração de lembretes para gastos recorrentes (via `flutter_local_notifications`).
* **Relatórios Visuais (Planejado):** Telas dedicadas para gráficos e análises financeiras (utilizando `fl_chart`).

---

## 🛠️ Tecnologias Utilizadas

Este projeto foi construído sobre a *framework* Flutter, utilizando as seguintes bibliotecas principais:

* **Framework:** **Flutter** (Dart)
* **Gerenciamento de Estado:** **Riverpod**
* **Banco de Dados Local:** **Hive** (chave-valor rápido e offline)
* **Geração de IDs:** **UUID**
* **Datas e Localização:** **intl** e **timezone**
* **Notificações:** **flutter_local_notifications**
* **Componentes de UI:** **table_calendar** e **fl_chart**

---

## 🏗️ Estrutura do Projeto

O projeto segue a arquitetura M.V.C. (Model-View-Controller) adaptada para o Riverpod, com foco em separação de responsabilidades:

my_gastos_app/ ├── lib/ │ ├── main.dart # Inicializa Hive e serviços │ │ │ ├── models/ # Modelos de dados (Gasto, Categoria) com Adapters Hive (.g.dart) │ │ │ ├── services/ # Lógica de persistência (HiveService) e Notificações │ │ │ ├── providers/ # Controllers e Lógica de Estado (Riverpod Notifiers) │ │ │ ├── screens/ # Telas principais (Home, AddGasto, Categorias, etc.) │ │ │ ├── widgets/ # Componentes de UI reutilizáveis (CardGasto, CategoriaItem) │ │ │ └── utils/ # Utilitários (AppColors, rotas, etc.) │ └── android/ # Configurações de build nativas (Gradle)


---

## ⚙️ Configuração e Instalação

Para configurar e rodar o projeto localmente, siga os passos abaixo:

### 1. Clonar o Repositório


git clone [https://github.com/SEU_USUARIO/my_gastos_app.git](https://github.com/SEU_USUARIO/my_gastos_app.git)
cd my_gastos_app
2. Instalar Dependências
Garanta que todas as dependências listadas no pubspec.yaml estejam instaladas:



flutter pub get
3. Gerar Arquivos Hive
O projeto utiliza code generation (build_runner) para criar os adaptadores do Hive (.g.dart). Este passo é obrigatório antes de rodar o aplicativo pela primeira vez:



flutter pub run build_runner build --delete-conflicting-outputs
4. Rodar o Aplicativo
Após a geração de código, execute o projeto em um emulador ou dispositivo conectado:



flutter run
 Build para Produção (APK)
Para gerar um arquivo APK de produção otimizado para distribuição, use o comando:



flutter build apk --release
O arquivo final estará disponível em: build/app/outputs/flutter-apk/app-release.apk.

 Contribuição
Contribuições são bem-vindas! Se você tiver sugestões, relatórios de bugs ou quiser implementar novas funcionalidades (como os gráficos em relatorios_screen.dart), sinta-se à vontade para abrir uma issue ou enviar um Pull Request.
 Licença
Este projeto está licenciado sob a licença MIT License (ou a licença de sua preferência).
