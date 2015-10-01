################################################################################
#
# perl-forks
#
################################################################################

PERL_FORKS_VERSION = 0.36
PERL_FORKS_SOURCE = forks-$(PERL_FORKS_VERSION).tar.gz
PERL_FORKS_SITE = $(BR2_CPAN_MIRROR)/authors/id/R/RY/RYBSKEJ
PERL_FORKS_DEPENDENCIES = perl
PERL_FORKS_LICENSE = Artistic or GPLv1+
PERL_FORKS_LICENSE_FILES = LICENSE

$(eval $(perl-package))
# http://search.cpan.org/CPAN/authors/id/R/RY/RYBSKEJ/forks-0.36.tar.gz