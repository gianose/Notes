<h1>Symfony</h1>

<ul>
	<li><a href="#doctrine" >Databases and Doctrine</a>
		<ul>
			<li><a href="#setdbutf8">Setup Database to be UTF8</a></li>
			<li><a href="#gdb">Generate empty DB</a></li>
			<li><a href="#cdb">Configuring the Database</a></li>
			<li><a href="#create_entity_class">Creating Entity Class</a></li>
			<li><a href="#mapping_info">Add Mapping Information</a></li>
			<li><a href="#generate_getters_and_setters">Generating Getters and Setters</a></li>
			<li><a href="#create_table_schema">Creating the Database Tables/Schema</a></li>
			<li><a href="#persisting_objects_to_the_database">Persisting Objects to the Database</a>
				<ul>
					<li><a href="#product_controller_add">Product Controller</a></li>
					<li><a href="#product_route_add">Product Route</a></li>
				</ul>
			</li>
			<li><a href="#fetching_objects_from_the_database">Fetching Objects from the Database</a>
				<ul>
					<li><a href="#product_controller_fetch" >Product Controller</a></li>
					<li><a href="#product_route_fetch" >Product Route</a></li>
					<li><a href="#repository_class">repository class</a></li>
				</ul>
			</li>
			<li><a href="#updating_an_object">Updating an Object</a></li>
			<li><a href="#deleting_an_object">Deleting an Object</a></li>
			<li><a href="#entity_relationship">Entity Relationships/Associations</a>
				<ul>
					<li><a href="#relationship_mapping_metadata">Relationship Mapping Metadata</a></li>
				</ul>
			</li>
		</ul>
	</li>
	<li><a href="#notes">Notes</a>
		<ul>
			<li><a href="#doctrine_create_entity_class">Doctrine create entity class</a></li>
			<li><a href="#doctrine_create_getter_and_setters">Doctrine create getters and setters</a></li>
		</ul>
	</li>
</ul>

<h2 id="doctrine">Databases and Doctrine</h2>

<h4 id="setdbutf8">Setup Database to be UTF8</h4>

<pre><code>
&#35; app/config/config.yml
doctrine:
    dbal:
        driver:   pdo_mysql
         .......
         charset: utf8mb4
         default_table_options:
         charset: utf8mb4
         collate: utf8mb4_unicode_ci
</code></pre>

<h4 id="cdb">Configuring the Database</h4>

* Configure database connection information. This information is configured in `app/config/parameters.yml`.
<pre><code>
&#35; This file is auto-generated during the composer install
parameters:
    database_host: localhost
    database_port: 3306
    database_name: test_project
    database_user: root
    database_password: &#91;database_password&#93;
</code></pre>

<h4 id="gdb"> Generate empty DB </h4>

<pre><code>&#36; php bin/console doctrine:database:create</code></pre>

<h4 id="create_entity_class">Creating Entity Class</h4>

<pre><code>
&#60;&#63;php
namespace AppBundle\Entity;

class Product{
  private &#36;name, &#36;price, &#36;description;

}
&#63;&#62;
</code></pre>


<h4 id="mapping_info">Add Mapping Information</h4>

* Doctrine allows you to fetch entire objects out of the database, and to persist entire objects to the database
* Map your database <b>tables</b> to specific PHP <b>classes</b>: the columns on those  <b>tables</b> must be mapped to specific properties on their corresponding PHP  <b>classes</b>.
* Mapping information is provided in the form of <b>metadata</b>:

<pre><code>
&#35; src/AppBundle/Resources/config/doctrine/Product.orm.yml
AppBundle\Entity\Product:
    type: entity
    table: product
    id:
        id:
            type: integer
            generator: { strategy: AUTO }
    fields:
        name:
            type: string
            length: 100
        price:
            type: decimal
            scale: 2
        description:
            type: text
</code></pre>

<h4 id="generate_getters_and_setters">Generating Getters and Setters</h4>
* Use the following to generate the boiler plate getter and setter methods for the <code>Product</code> class
<pre><code>&#36; php bin/console doctrine:generate:entities AppBundle/Entity/Product</code></pre>

<h4 id="create_table_schema">Creating the Database Tables/Schema</h4>

<pre><code>&#36; php bin/console doctrine:schema:update --force</code></pre>

<h4 id="persisting_objects_to_the_database">Persisting Objects to the Database</h4>
<h5 id="product_controller_add">Product Controller</h5>

<pre><code>
// src/AppBundle/Controller/ProductController.php

<?php
	use AppBundle\Entity\Product;

	use Symfony\Component\HttpFoundation\Response;
	use Symfony\Bundle\FrameworkBundle\Controller\Controller;

	Class ProductController extends Controller {
		public function addAction()
		{
  			$product = new Product();
    		$product->setName('Keyboard')->setPrice(19.99')->setDescription('Ergonomic and stylish!');

    		$em = $this->getDoctrine()->getManager();

			// tells Doctrine you want to (eventually) save the Product (no queries yet)
    		$em->persist($product);

    		// actually executes the queries (i.e. the INSERT query)
    		$em->flush();

    		return new Response('Saved new product with id '.$product->getId());
		}
	}
?>
</code></pre>

<h5 id="product_route_add">Product Route</h5>

<pre><code>
app/config/routing.yml

product:
path: /product
defaults: { _controller: AppBundle:Product:add }
</code></pre>

<h4 id="fetching_objects_from_the_database">Fetching Objects from the Database</h4>
<h5 id="product_controller_fetch">Product Controller</h5>

<pre><code>
// src/AppBundle/Controller/ProductController.php

<?php
    use AppBundle\Entity\Product;

	use Symfony\Component\HttpFoundation\Response;
	use Symfony\Bundle\FrameworkBundle\Controller\Controller;

	Class ProductController extends Controller {
			public function pullAction($pid) {
  			$product = $this->getDoctrine()->getRepository('AppBundle:Product')->find($pid);

  			if (!$product) {
    			throw $this->createNotFoundException('No product found for id '.$pid);
  			}

  			return $this->render('product/table.html.twig', array('product' => $product));
		}
	}
?>
</code></pre>

<h5 id="product_route_fetch">Product Route</h5>

<pre><code>
# app/config/routing.yml

product:
path: /product/{pid}
defaults: { _controller: AppBundle:Product:pull, pid: false }
</code></pre>

----

<h5 id="repository_class">repository class</h5>

<pre><code>
// repository:  PHP class whose only job is to help you fetch entities of a certain class.
$repository = $this->getDoctrine()->getRepository('AppBundle:Product');

// query for a single product by its primary key (usually "id")
$product = $repository->find($productId)

// dynamic method names to find a single product based on a column value
$product = $repository->findOneById($productId);
$product = $repository->findOneByName('Keyboard');

// dynamic method names to find a group of products based on a column value
$products = $repository->findByPrice(19.99);

// find *all* products
$products = $repository->findAll();


// query for a single product matching the given name and price.
$product = $repository->findOneBy( array('name' => 'Keyboard', 'price' => 19.99));

// query for multiple products matching the given name, ordered by price
$products = $repository->findBy(
    array('name' => 'Keyboard'),
    array('price' =>'ASC')
);
</code></pre>
----

<h4 id="updating_an_object">Updating an Object</h4>

Updating an object involves just three steps:

<ol type ="1">
	<li>fetching the object from Doctrine;</li>
	<li>modifying the object;</li>
	<li>call flush() on the entity manager;</li>
</ol>

<h4 id="deleting_an_object">Deleting an Object</h4>

<ol type ="1">
	<li>fetching the object from Doctrine;</li>
	<li>call remove() on the entity manager;</li>
	<li>call flush() on the entity manager;</li>
</ol>

<h4 id="custom_repository_classes">Custom Repository Classes</h4>

It's a good practice to create a custom repository class for your entity; In order to isolate, reuse and test queries.

To do this, add the repository class name to your entity's mapping definition:

<pre><code>
&#35; src/AppBundle/Resources/config/doctrine/Product.orm.yml
AppBundle\Entity\Product:
    type: entity
    repositoryClass: AppBundle\Entity\ProductRepository
    &#35; ....
</code></pre>

Utilize Doctrine to generate empty repository class.
<pre><code>
php bin/console doctrine:generate:entities AppBundle
</code></pre>

Next, add new method - findAllOrderedByName() - to the newly-generated ProductRepository class.

<pre><code>
&#60;&#63;php
// src/AppBundle/Entity/ProductRepository.php
namespace AppBundle\Entity;

/**
 * ProductRepository
 *
 * This class was generated by the Doctrine ORM. Add your own custom
 * repository methods below.
 */
class ProductRepository extends \Doctrine\ORM\EntityRepository
{
  public function findAllOrderedByName(){
    return $this->createQueryBuilder('p')->orderBy('p.name', 'ASC')->getQuery()->getResult();
  }
}
</code></pre>

<h4 id='entity_relationship'>Entity Relationships/Associations</h4>

* Each product belongs to exactly one category.
* Need Category class, and a way to relate a Product object to a Category object.

Let Doctrine create the Category class.

<pre><code>
$ php bin/console doctrine:generate:entity --no-interaction \
	--entity="AppBundle:Category" \
	--fields="name:string(255)"
	</code></pre>

<h5 id='relationship_mapping_metadata'>Relationship Mapping Metadata</h5>

* From Perspective of Product: many-to-one
* To relate the Product and Category entities, do the following in Product.orm.yml.

<pre><code>
&#35; src/AppBundle/Resources/config/doctrine/Product.orm.yml
AppBundle\Entity\Product:
    type: entity
    # ...
    manyToOne:
        category:
            targetEntity: Category
            inversedBy: products
            joinColumn:
                name: category_id
                referencedColumnName: id
</code></pre>

* In addition to adding the following private property to the Product class.

<pre><code>
class Product{
	private $category;
}
</code></pre>

* From Perspective of Category: one-to-many:

<pre><code>
// src/AppBundle/Entity/Category.php

// ...
use Doctrine\Common\Collections\ArrayCollection;

class Category
{
    // ...

    /**
     * @ORM\OneToMany(targetEntity="Product", mappedBy="category")
     */
    private $products;

    public function __construct()
    {
        $this->products = new ArrayCollection();
    }
}
</code></pre>


<h2 id="notes">Notes</h2>
<h4 id="doctrine_create_entity_class">Doctrine create entity class</h4>
<pre><code>&#36; php bin/console doctrine:generate:entity</code></pre>
<h4 id="doctrine_create_getter_and_setters">Doctrine create getters and setters</h4>
<pre><code>&#36; php bin/console doctrine:generate:entities AppBundle</code></pre>
