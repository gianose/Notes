## Symfony

- [My First Page](#my-first-page)
  - [Creating a Page: Route and Controller](#creating-a-page:-route-and-controller)
  - [Rendering a Template](#rendering-a-template)
  - [Checking out the Project Structure](#checking-out-the-project-structure)

### My First Page

Creating a new page - whether it's an _HTML_ page or a _JSON_ endpoint - is a simple two-step process:

1. Create a **route**: A route is the URL (e.g. /about) to your page and points to a controller;

2. Create a **controller**: A controller is the PHP function you write that builds the page.

__Important__

* **Routes** live in: `${CURRENT_PROJECT}/app/config/`.
* **Controllers** live in: `${CURRENT_PROJECT}/src/AppBundle/Controller/`
* **Views** live in: `${CURRENT_PROJECT}/app/Resources/views/`

#### Creating a Page: Route and Controller

In order to get a page up utilizing Symfony do the following:

* Place the following **route** in `${CURRENT_PROJECT}/app/config/routing.yml` to point to the **controller** `LuckyController.php` when we attempt to visit [localhost](http://localhost:8000/app_dev.php/lucky/number):

~~~yml
lucky_number:
    path: /lucky/number
    defaults: { _controller: AppBundle:Lucky:number }
~~~

* Place the `LuckyController.php` **controller** in `${CURRENT_PROJECT}/src/AppBundle/Controller/`. `LuckyController.php` will contain a "Controller class" and a "controller" method inside of it that will be executed when someone goes to /lucky/number:

~~~php
<?php
  namespace AppBundle\Controller;

  use Symfony\Component\HttpFoundation\Response;

  class LuckyController
  {
    public function numberAction()
    {
      $number = rand(0, 100);

      return new Response('<html><body>Lucky number: '.$number.'</body></html>');
    }
  }
?>
~~~

#### Rendering a Template
**Note:** Symfony comes with the templating language [`Twig:`](http://twig.sensiolabs.org/).

In order to return `HTML` from the **controller** do the following:
* Have `LuckyController.php` extend the Symfony's base Controller class:
~~~php
<?php
  namespace AppBundle\Controller;

  //...
  use Symfony\Bundle\FrameworkBundle\Controller\Controller;

  class LuckyController extends Controller
  { /*...*/ }
?>
~~~
* Utilize the `render()` method within the `numberAction()` method, passing it the relative path to the twig template and the `number` variable wrapped in an indexed array.
~~~php
<?php
  namespace AppBundle\Controller;

  use Symfony\Component\HttpFoundation\Response;
  use Symfony\Bundle\FrameworkBundle\Controller\Controller;

  class LuckyController extends Controller
  {
    public function numberAction()
    {
      $number = rand(0, 100);

      return $this->render('lucky/number.html.twig', ['number' => $number]);
    }
  }
?>
~~~

* Finally place place the following template in `${CURRENT_PROJECT}/app/Resources/view/lucky`:
~~~html
{# app/Resources/views/lucky/number.html.twig #}
<h1>Your lucky number is {{ number }}</h1>
~~~
__Note__: `mkdir -p ${CURRENT_PROJECT}/app/Resources/view/lucky`

#### Checking out the Project Structure

- `app/`
  - Contains things like configuration and templates. Basically, anything that is not PHP code goes here.
- `src/`
  - Your PHP code lives here; 99% of the time, you'll be working in src/ (PHP files) or app/ (everything else).
- `bin/`
  - Executable files including bin/console.
- `tests/`
  - The automated tests (e.g. Unit tests) for your application live here.
- `var/`
  - This is where automatically-created files are stored, like cache files (var/cache/) and logs (var/logs/).
- `vendor/`
  - Third-party (i.e. "vendor") libraries live here! These are downloaded via the Composer package manager.
- `web/`
  - This is the document root for your project: put any publicly accessible files here (e.g. CSS, JS and images).
