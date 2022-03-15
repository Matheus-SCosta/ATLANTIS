# ATLANTIS

## O que é o ATLANTIS?

O atlantis é um aplicativo que serve para automatizar o terraform em sua infraestrutura ouvindo webhooks do git sobre pull requests, ajudando a manter a colaboração de todos quanto ao projeto, já que resolve a questão de cada um executar o código terraform em seu próprio computador, dificultando por exemplo para saber sobre o estado de sua infraestrutura.


## Instalação:

O atlantis funciona com a maioria dos hosts git, como github, gitlab, Bitbucket, Azure DevOps por exemplo. **OBS: No nosso exemplo utilizaremos como exemplo o GitHub, porém as configurações para os outros hosts git está disponĩvel na documentação do atlantis**. O atlantis suporta todas as versões do terraform podendo ser configurado para usar versões diferentes para diferentes respositórios/projetos, suportando também todos os tipos de back-end do terraform, exceto o estado local.

O ideal é que seja criado um usuário dedicado para o uso do atlantis, para que não ocorra confusão nos comentários do pull requests. Em seguida é necessário criar um token de acesso pessoal, seguindo a documentação https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/#creating-a-token 
