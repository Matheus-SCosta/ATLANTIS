# ATLANTIS

## O que é o ATLANTIS?

O atlantis é um aplicativo que serve para automatizar o terraform em sua infraestrutura ouvindo webhooks do git sobre pull requests, ajudando a manter a colaboração de todos quanto ao projeto, já que resolve a questão de cada um executar o código terraform em seu próprio computador, dificultando por exemplo para saber sobre o estado de sua infraestrutura.


## INSTALAÇÃO:

O atlantis funciona com a maioria dos hosts git, como github, gitlab, Bitbucket, Azure DevOps por exemplo. **OBS: No nosso exemplo utilizaremos como exemplo o GitHub, porém as configurações para os outros hosts git está disponĩvel na documentação do atlantis**. O atlantis suporta todas as versões do terraform podendo ser configurado para usar versões diferentes para diferentes respositórios/projetos, suportando também todos os tipos de back-end do terraform, exceto o estado local.

O ideal é que seja criado um usuário dedicado para o uso do atlantis, para que não ocorra confusão nos comentários do pull requests. 

* Em seguida é necessário criar um token de acesso pessoal, seguindo a documentação https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/#creating-a-token. Esse token precisa ser passado para o comando atlantis na opção **--gh-token=token**.

* Necessário também a criação de segredos de webhook, pois o atlantis usa segredos do Webhook para validar se os webhooks que recebe do seu host Git são legítimos. Pode-se gerar um segredo online pelo link  https://www.browserling.com/tools/random-string. Ao gerar o segredo anote, para utilizar nos passos posteriores.

* Crie credenciais do provedor, será necessário nos passos posteriores.

* Para implantação pode ser usado várias formas, como implementar em kubernetes, docker e diretamente no servidor. No nosso exemplo mostrarei um exemplo em Docker. Para início, nossa infraestrutura estará na AWS em uma VPC e SUBNETS Públicas. Ao ter acesso a EC2, criaremos um Dockerfile com o seguinte conteúdo: 

```
FROM ghcr.io/runatlantis/atlantis:dev
ENV AWS_ACCESS_KEY_ID=AKIAVZZAYQ4MTZAKVM7U
ENV AWS_SECRET_ACCESS_KEY=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
ENV ATLANTIS_GH_WEBHOOK_SECRET=disazhwlzdbipzsesspwummekzxntarcvtmwgtueqosrbzfxsugvlqyszblqbkiygqmxtftsnrjgdmdepnjjqjmchyhkavpdlhrkgsxqlvghszymsmecpgeirnpvivkm
ENV ATLANTIS_GH_TOKEN=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
ENV ATLANTIS_GH_USER=Matheus-SCosta
ADD repos.yaml home/atlantis/repos.yaml   # Arquivo será criado durante a explicação.
ENTRYPOINT [ "atlantis", "server", "--repo-allowlist=*", "--repo-config=home/atlantis/repos.yaml" ]

```

A principio não será possível criar a imagem pois o arquivo repos.yaml ainda não foi criado. Você pode pega-lo no tópico posterior para conseguir criar a imagem. Então depois crie a imagem e suba o container com o comando **docker container run -p 80:4141 name_image**.

* Após subir o container é necessário configurar o webhook no GitHub. Para isso siga os passos: 
-> Selecione Webhooks ou Hooks na barra lateral 
-> Clique em Adicionar webhook 
-> defina Payload URL para http://$URL/events(ou https://$URL/eventsse você estiver usando SSL) onde $URLé onde o Atlantis está hospedado. 
-> Certifique-se de adicionar/events 
-> verifique novamente se você adicionou /eventsao final do seu URL. 
-> defina o tipo de conteúdo paraapplication/json 
-> defina o segredo para o segredo do Webhook que você gerou anteriormente
OBSERVAÇÃO Se você estiver adicionando um webhook a vários repositórios, cada repositório precisará usar o mesmo segredo.
-> selecione Deixe-me selecionar eventos individuais
-> verifique as caixas
-> Revisões de solicitação de pull
    Empurrões
    Emitir comentários
    Solicitações de pull
    deixar Ativo marcado
->clique em Adicionar webhook


* Para testar se há conexão entre o webhook e o servidor do atlantis, crie uma branch a partir da master/main, faça algum tipo de alteração, dê o push para o repositório e em seguida crie um pull requests e comente com o atlantis plan -d **nome_diretorio** e veja se há alguma resposta do atlantis com o output do terraform. Em seguida observe se há saida de logs do container. Para visualizar os logs, utilize o subcomando **logs** do docker. Em caso de não ter nenhum retorno, verifique suas configurações.


## CONFIGURAÇÃO:

Existem três métodos para configurar o Atlantis:

* Passando flags para o atlantis servercomando
* Criando um arquivo de configuração de repositório do lado do servidor e usando o --repo-config sinalizador
* Colocando um atlantis.yaml arquivo na raiz de seus repositórios do Terraform

No nosso exemplo vamos fazer a criação de um arquivo do lado do servidor e a criação de um arquivo atlantis.yaml nos repositórios.


* O arquivo do lado do servidor se chamará repos.yaml, mas seu nome pode ser opcional e terá o seguinte conteúdo:

    ```
    repos:
    - id: github.com/Matheus-SCosta/TERRAFORM
      allowed_overrides: [workflow]
      apply_requirements: [approved]
      allow_custom_workflows: true

    - id: github.com/Matheus-SCosta/ATLANTIS
      allowed_overrides: [workflow]
      apply_requirements: [mergeable]
      allow_custom_workflows: true
    ```

    Nesse caso, foi criado uma configuração para 2 repositórios, com configurações diferentes para cada um. É possível realizar vários tipo de configuração para esse arquivo, com diversas opções mostradas com mais detalhes na documentação do atlantis https://www.runatlantis.io/docs/server-side-repo-config.html#example-server-side-repo.


* Criaremos agora o arquivo do lado do repositório, que deve obrigatoriamente ser chamado de atlantis.yaml. No nosso caso terá o seguinte conteúdo:

    ```
    version: 3
    projects:

    - dir: .
    workflow: custom1
    terraform_version: v1.1.4 

    workflows:
      custom1:
        plan:
            steps:
            - init
            - run: echo "Executando terraform plan"
            - plan
        apply:
            steps:
            - run: echo "Executando terraform apply"
            - apply  
    ```

Não será abordado nesse tópico mas deixando claro a opção de implementar workspaces pré-fluxo e pós-fluxos. Por exemplo pode ser necessário que algum script seja executado antes que o atlantis faça o plan ou então que após o plan seja necessário que seja executado o infracost.


