## Symfony

- [Routing](#routing)
  - [Routing Examples](#routing-examples)
  - [Adding wildcard Requirements](#adding-wildcard-requirements)

### Routing

A route is a map from a URL path to a controller.

#### Routing Examples

In order to match a _URL_ like [`/blog`](http://127.0.0.1:8000/blog) of `/blog/*` do the following:

__Note__: `*` in the above _URL_ is a wild card in other words it can be any string.

* Place the following **route** in `${CURRENT_PROJECT}/app/config/routing.yml`:

~~~yml
# app/config/routing.yml
blog_list:
    path:      /blog
    defaults:  { _controller: AppBundle:Blog:list }

blog_show:
    path:      /blog/{slug}
    defaults:  { _controller: AppBundle:Blog:show }
~~~
* Place the the corresponding **controller** in `${CURRENT_PROJECT}/src/AppBundle/Controller/`:

~~~php
<?php
  namespace AppBundle\Controller;``

  use Symfony\Component\HttpFoundation\Response;
  use Symfony\Bundle\FrameworkBundle\Controller\Controller;

  class BlogController extends Controller {
    public function listAction(){
      $entries = [
        "First Post" => "Content of the first post",
        "Another Post" => "Content of the second post",
      ];

      return $this->render('blog/index.html.twig', ['blog_entries' => $entries]));
    }

    public function showAction($slug){}
  }

?>
~~~
* Finally place the corresponding **view**\template in `${CURRENT_PROJECT}/app/Resources/views/`:

~~~html
{# app/Resources/views/blog/index.html.twig #}
{% extends 'base.html.twig' %}

{% block title %}My cool blog posts{% endblock %}

{% block body %}
    {% for title,body in blog_entries %}
        <h2>{{ title }}</h2>
        <p>{{ body }}</p>
    {% endfor %}
{% endblock %}
~~~

If the user goes to [`/blog`](http://127.0.0.1:8000/blog), the first route is matched and `listAction()` is executed;
If the user goes to `/blog/*`, the second route is matched and `showAction()` is executed.
> `$slug` represents a paramater that is passed to the `showAction()` method.

#### Adding wildcard Requirements

##### Earlier Routes always Win

If a request matches two routes, then the first route always wins. By adding _requirements_ to the first route, you can make each route match in just the right situations.

__Example__

Both `/blog/{page}` and `/blog/{slug}` will match `/blog/*`.
In order to prevent this from occuring something similar to the following can be placed in `${CURRENT_PROJECT}/app/config/routing.yml`.

~~~yml
# app/config/routing.yml
blog_list:
    path:      /blog/{page}
    defaults:  { _controller: AppBundle:Blog:list }
    requirements:
        page: '\d+'

blog_show:
    # ...
~~~

Since the parameter requirements are regular expressions, the complexity and flexibility of each requirement is entirely up to you.

#### Giving placeholders a Default Value

When a `{placeholder}` is added to a route it provides a default value for a `{wildcard}` when a value is not provided.

__Example__

Referencing the previous example, if the user goes to `/blog/1` it will match. But if the user goes to `/blog`, it will not match. To remedy this place route similer to the followihg in `${CURRENT_PROJECT}/app/config/routing.yml`:

~~~yml
# app/config/routing.yml
blog_list:
    path:      /blog/{page}
    defaults:  { _controller: AppBundle:Blog:list, page: 1 }
    requirements:
        page: '\d+'

blog_show:
    # ...
~~~

Now, when the user goes to `/blog`, the `blog_list` route will match and $page will default to a value of `1`.
