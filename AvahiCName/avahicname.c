#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <avahi-client/client.h>
#include <avahi-client/publish.h>
#include <avahi-common/alternative.h>
#include <avahi-common/simple-watch.h>
#include <avahi-common/malloc.h>
#include <avahi-common/error.h>

static AvahiEntryGroup * _group = NULL;
static AvahiSimplePoll * _poll  = NULL;
static const char ** _cnames    = NULL;

/* Called whenever the entry group state changes */
static void entry_group_callback(AvahiEntryGroup *g, AvahiEntryGroupState state, AVAHI_GCC_UNUSED void *userdata) 
{
  assert(g == _group || _group == NULL);
  _group = g;

  switch (state) {
  case AVAHI_ENTRY_GROUP_FAILURE :
    fprintf(stderr, "Entry group failure: %s\n", avahi_strerror(avahi_client_errno(avahi_entry_group_get_client(g))));
    avahi_simple_poll_quit(_poll);
    break;

  case AVAHI_ENTRY_GROUP_COLLISION : 
  case AVAHI_ENTRY_GROUP_ESTABLISHED :
  case AVAHI_ENTRY_GROUP_UNCOMMITED:
  case AVAHI_ENTRY_GROUP_REGISTERING:
    /* empty */
    break;
  }
}

static void create_cnames(AvahiClient *c) 
{
  /* If this is the first time we're called, let's create a new entry group if necessary */
  if ((!_group)&&(!(_group = avahi_entry_group_new(c, entry_group_callback, NULL))))
    {
      fprintf(stderr, "avahi_entry_group_new() failed: %s\n", avahi_strerror(avahi_client_errno(c)));
      goto fail;
    }

  /* If the group is empty (either because it was just created, or because it was reset previously, add our entries. */
  if (avahi_entry_group_is_empty(_group)) 
    {
      char hostname[HOST_NAME_MAX+64] = ".";  /* this dot will be overwritten with a count-byte, below */
      if (gethostname(&hostname[1], sizeof(hostname)-1) < 0) perror("gethostname");
      strncat(hostname, ".local", sizeof(hostname));
      hostname[sizeof(hostname)-1] = '\0';  /* paranoia? */

      /* Convert the hostname string into DNS's labelled-strings format */
      int hostnameLen = strlen(hostname);
      char count = 0;
      int i;
      for (i=hostnameLen-1; i>=0; i--)
	{
	  if (hostname[i] == '.')
	    {
	      hostname[i] = count;
	      count = 0;
	    }
	  else count++;
	}

      for (i=0; (_cnames[i] != NULL); i++)
	{
	  int ret = avahi_entry_group_add_record(_group, AVAHI_IF_UNSPEC, AVAHI_PROTO_UNSPEC, (AvahiPublishFlags)(AVAHI_PUBLISH_USE_MULTICAST|AVAHI_PUBLISH_ALLOW_MULTIPLE), _cnames[i], AVAHI_DNS_CLASS_IN, AVAHI_DNS_TYPE_CNAME, AVAHI_DEFAULT_TTL, hostname, hostnameLen+1); 
	  if (ret >= 0) printf("Published DNS-SD hostname alias [%s]\n", _cnames[i]);
	  else
	    {
	      fprintf(stderr, "Failed to add CNAME record [%s]: %s\n", _cnames[i], avahi_strerror(ret));
	      goto fail;
	    }
	}

      int ret = avahi_entry_group_commit(_group);
      if (ret < 0)
	{
	  fprintf(stderr, "Failed to commit entry group: %s\n", avahi_strerror(ret));
	  goto fail;
	}
    }
  return;

 fail:
  avahi_simple_poll_quit(_poll);
}

static void client_callback(AvahiClient *c, AvahiClientState state, AVAHI_GCC_UNUSED void * userdata) 
{
  /* Called whenever the client or server state changes */
  switch (state) 
    {
    case AVAHI_CLIENT_S_RUNNING:
      create_cnames(c);
      break;

    case AVAHI_CLIENT_FAILURE:
      fprintf(stderr, "Client failure: %s\n", avahi_strerror(avahi_client_errno(c)));
      avahi_simple_poll_quit(_poll);
      break;

    case AVAHI_CLIENT_S_COLLISION:
    case AVAHI_CLIENT_S_REGISTERING:
      if (_group) avahi_entry_group_reset(_group);
      break;

    case AVAHI_CLIENT_CONNECTING:
      /* do nothing */
      break;
    }
}

/** cnames should be a NULL-terminated array of alias hostnames for this host.
 * Example invocation:  const char * cnames = {"foo.local", "bar.local", NULL}; PublishAvahiCNames(cnames);  
 * Note that this function normally does not ever return!
 */
void PublishAvahiCNames(const char ** cnames)
{
  _cnames = cnames;

  /* Allocate main loop object */
  _poll = avahi_simple_poll_new();
  if (_poll)
    {
      int error;
      AvahiClient * client = avahi_client_new(avahi_simple_poll_get(_poll), (AvahiClientFlags) 0, client_callback, NULL, &error);
      if (client)
	{
	  avahi_simple_poll_loop(_poll);
	  avahi_client_free(client);
	}
      else fprintf(stderr, "Failed to create Avahi client: %s\n", avahi_strerror(error));

      avahi_simple_poll_free(_poll);
    }
  else fprintf(stderr, "Failed to create Avahi simple poll object.\n");
}

/* Unit test */
int main(int argc, char ** argv)
{
  if (argc > 1) PublishAvahiCNames((const char **) &argv[1]);
  else printf("Usage:  ./publish_cnames foo.local bar.local [...]\n");
  return 0;
}
