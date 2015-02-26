postfix-gmail-formula
=====================

Saltstack formula to install postfix and forward mail through
Gmail. Mostly following `this tutorial
<https://rtcamp.com/tutorials/linux/ubuntu-postfix-gmail-smtp/>`_.

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.

.. contents::
    :local:

``postfix-gmail``
-----------

Installs postfix and configures SMTP relay through GMail.

Requires some pillars:

* ``postfix-gmail:email`` - your gmail email
* ``postfix-gmail:password`` - your gmail password
