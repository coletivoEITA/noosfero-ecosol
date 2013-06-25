

escambo = {

};

escambo.home = {

  scrollLeft: function() {

  },
  scrollRight: function() {

  },
};

escambo.signup = {

  enterprise: {

    find: function() {
      jQuery('#enterprise-register').toggle();
      jQuery('#enterprise-find').toggle();
    },
    register: function() {
      this.find();
    },
  },
}

jQuery('.scroll-left').click(escambo.home.scrollLeft);
