# Plano

* Subir localmente em um ambiente mais estruturado:
    1. escrever Dockerfile: https://backstage.io/docs/deployment/docker/#host-build
    2. 


# Decisões

1. Compilar core localmente ou utilizar uma imagem Docker? (atualmente compilamos localmente)
    * OBS: Backstage não fornece imagem pronta. Se optarmos por usar imagem do core, precisaremos manter a nossa.

# Questões

1. O que pode ser alterado no Backstage sem alterar o core?
    * Dá pra alterar interface? Página de catálogo? Página de templates?
2. Como conectar os plugins criados com o core do Backstage?
    * Ao que parece, é sempre necessário mexer no código do core para adicionar um novo plugins, mesmo que seja um plugin externo.
    * A mudança é maior quando o plugin é de frontend.
3. É possível desacoplar o Frontend do Backend? 
    * Sim, é possível: https://backstage.io/docs/deployment/docker/#separate-frontend


# Features

1. Sistema de notificação:
    * nova versão possui sistema builtin: https://backstage.io/docs/notifications/

# Plugins:

1. Announcements: https://github.com/procore-oss/backstage-plugin-announcements/
2. ArgoCD: https://roadie.io/backstage/plugins/argo-cd/?
3. Bulletins: https://github.com/v-ngu/backstage-plugin-bulletin-board
4. Catalog Graph: https://github.com/backstage/backstage/blob/master/plugins/catalog-graph/README.md
5. Cost Insights: https://github.com/backstage/community-plugins/tree/main/workspaces/cost-insights/plugins/cost-insights
6. Entity Feedback: https://github.com/backstage/community-plugins/tree/main/workspaces/entity-feedback/plugins/entity-feedback
7. Entity Validation: https://github.com/backstage/community-plugins/tree/main/workspaces/entity-validation/plugins/entity-validation
8. Feedback: https://github.com/janus-idp/backstage-plugins/tree/main/plugins/feedback#readme
9. Gitlab: https://github.com/immobiliare/backstage-plugin-gitlab
10. Gitlab Pipelines: https://platform.vee.codes/plugin/gitlab-pipelines/
11. Homepage: https://github.com/backstage/backstage/blob/master/plugins/home/README.md
12. Infra Wallet: https://github.com/electrolux-oss/infrawallet/blob/main/README.md
13. Logs Kubernetes: https://github.com/jfvilas/kubelog
14. Criar entidades a partir de objetos do kubernets: https://github.com/AntoineDao/backstage-provider-kubernetes#readme
15. Open Cost: https://github.com/backstage/community-plugins/blob/main/workspaces/opencost/plugins/opencost/README.md
16. Pager Duty: https://pagerduty.github.io/backstage-plugin-docs/index.html
17. Organizar entidades que não são dependentes umas das outras: https://github.com/backstage/community-plugins/tree/main/workspaces/playlist/plugins/playlist
18. Adicionar novos tipos de relações entre entidades: https://github.com/dweber019/backstage-plugins/tree/main/plugins/relations
19. Mostrar o README.md do projeto: https://github.com/AxisCommunications/backstage-plugins/blob/main/plugins/readme/README.md
20. SonarCube: https://github.com/backstage/community-plugins/blob/main/workspaces/sonarqube/plugins/sonarqube/README.md
