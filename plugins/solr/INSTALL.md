(THIS INSTALL IS INCOMPLETE)

What is this?
=============
Solr is a enterprise-grade search engine. This plugin enables solr to work in noosfero, with some standard models and fields indexed.

Dependencies
============

apt-get install openjdk-6-jre

* Solr: http://lucene.apache.org/solr

Instalation
===========

$ rake solr:download

Running the server
==================
Run Solr

$ rake solr:start

Configuration
=============
The solr plugin for noosfero creates its index based on a standard set of models and model fields.

These models and fields can be changed, in the folder `plugins/solr/lib/ext` there are the indexed models. In a model, the method `acts_as_faceted` defines the facets to be used as filter. The method `acts_as_searchable` defines the search fields to be compared.

## Profile
A main usage of solr search engine is to provide full text search into profiles. When enabled, solr plugin changes the search pages for profile, allowing profile filtering by region or category.

### Categories
To use categories as a facet, they must have as parent a top level category. For instance, you waht to filter the profiles by two facets, "Economic Sectors" and "Enterprise size". Then you have several categories, that can fit in one top level category or other. Then you can put these top level categories in an array of the top level category ids, in the instance method `environment.solr_plugin_top_level_category_as_facet_ids`. Save this property (in a rails console) and reindex.

### Regions
A Region facet is automatically created for profiles. A Region is a kind of category, and is subclassed in a City and State. To be used for solr, a profile must have a Region object set in its `region` property.