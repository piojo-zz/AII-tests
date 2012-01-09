####################################################################
# Distribution Makefile
####################################################################

.PHONY: configure install clean

all: configure man

#
# BTDIR needs to point to the location of the build tools
#
BTDIR := quattor-build-tools
#
#
_btincl   := $(shell ls $(BTDIR)/quattor-buildtools.mk 2>/dev/null || \
             echo quattor-buildtools.mk)
include $(_btincl)

_podopt += --section=8

# Configuration

AII_SOURCES := aii-installfe aii-shellfe aii-dhcp

AII_ALL_SOURCES := $(AII_SOURCES) aii-installack.cgi

TPL_FILES := $(shell ls \
	$(addprefix TPL/, quattor/aii/*tpl.cin quattor/aii/rpms/*tpl.cin site/*.tpl.cin) \
	2>/dev/null |sed -e 's/.tpl.cin/.tpl/' || echo )

AII_TEMPLATES := quattor/aii/schema.tpl \
	quattor/aii/config.tpl \
	site/aii.tpl

AII_EXAMPLES := localboot.cfg $(addsuffix .conf, $(AII_SOURCES))

AII_DOC := aii.pod \
	aii-hooks.pod \
    aii-update.pod

AII_MAN := aii.8.gz \
	aii-dhcp.8.gz \
	aii-shellfe.8.gz \
	aii-installfe.8.gz \
	aii-hooks.8.gz \
	aii-update.8.gz


AII_TPL_FILES       := $(TPL_FILES)
_SRC_FILES          += $(addsuffix .cin, $(AII_ALL_SOURCES) $(AII_TPL_FILES) )
_DIRTY_TPL_FILES    += $(addsuffix .cin, $(AII_TPL_FILES) )

configure: tplclean check \
	$(AII_ALL_SOURCES) \
	$(addprefix eg/, $(addsuffix .conf, ${AII_SOURCES}))\
	$(TPL_FILES) \
	$(AII_DOC)

####################################################################
# Install
####################################################################

install: configure man
	@echo installing ...
	@mkdir -p $(PREFIX)/$(QTTR_SBIN)
	@mkdir -p $(PREFIX)/$(QTTR_ETC)
	@mkdir -p $(PREFIX)/$(QTTR_MAN)/man$(MANSECT)
	@mkdir -p $(PREFIX)/$(PAN_TEMPLATESDIR)/$(PAN_NAMESPACE_SDIR)/$(PAN_QUATTOR_NS)/$(COMP)
	@mkdir -p $(PREFIX)/$(PAN_TEMPLATESDIR)/$(PAN_NAMESPACE_SDIR)/$(PAN_SITE_NS)
	@mkdir -p $(PREFIX)/$(QTTR_DOC)
	@mkdir -p $(PREFIX)/$(QTTR_DOC)/eg
	@mkdir -p $(PREFIX)/$(QTTR_LIB)/aii/nbp

	@for i in $(AII_SOURCES) aii-installack.cgi ; do \
		install -m 0755 $$i $(PREFIX)/$(QTTR_SBIN)/$$i ; \
	done
	@for i in $(AII_SOURCES) ; do \
		install -m 0444 $$i.$(MANSECT).gz \
			$(PREFIX)$(QTTR_MAN)/man$(MANSECT)/$$i.$(MANSECT).gz ; \
	done
	@for i in $(AII_DOC) ; do \
		file=`basename $$i .pod`; \
		install -m 0444 $$file.$(MANSECT).gz \
			$(PREFIX)$(QTTR_MAN)/man$(MANSECT)/$$file.$(MANSECT).gz ; \
	done
	@for i in LICENSE ChangeLog README ; do \
		install -m 0444 $$i $(PREFIX)/$(QTTR_DOC)/$$i ; \
	done
	@for i in $(AII_EXAMPLES) ; do \
		install -m 0444 eg/$$i $(PREFIX)/$(QTTR_DOC)/eg/$$i ; \
	done
	@for i in $(AII_TEMPLATES) ; do \
		install -m 0444 TPL/$$i $(PREFIX)/$(PAN_TEMPLATESDIR)/$(PAN_NAMESPACE_SDIR)/$$i ; \
	done

	@install -m 0444 eg/localboot.cfg $(PREFIX)/$(QTTR_LIB)/aii/nbp/localboot.cfg


man: configure
	@for i in $(AII_SOURCES) $(AII_DOC) ; do \
		file=`basename $$i .pod`; \
		echo creating man page for $$file ; \
		pod2man $(_podopt) $$i > $$file.$(MANSECT) ; \
		gzip -f $$file.$(MANSECT) ; \
	done

####################################################################


clean::
	@echo cleaning $(NAME) files ...
	@rm -f $(AII_SOURCES) aii-installack.cgi $(AII_DOC) $(AII_MAN) \
		$(addprefix eg/, $(AII_TPL_FILES) $(addsuffix .conf, $(AII_SOURCES)))\
		$(addsuffix *.bak, $(AII_TPL_FILES) $(addprefix TPL/, \
			$(AII_TEMPLATES)) ) \
		$(AII_TPL_FILES)

