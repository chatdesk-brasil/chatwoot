export const getters = {
  getContacts($state) {
    return $state.sortOrder.map(contactId => $state.records[contactId]);
  },
  getUIFlags($state) {
    return $state.uiFlags;
  },
  getContact: $state => id => {
    const contact = $state.records[id];
    return contact || {};
  },
  getMeta: $state => {
    return $state.meta;
  },
  getAppliedContactFilters: _state => {
    return _state.appliedFilters;
  },
  getWhatsappContacts: $state => {
    return $state.whatsappContacts;
  },

  getCorruptedContacts: $state => {
    return Object.values($state.records).filter(
      contact =>
        contact.custom_attributes && contact.custom_attributes.contact_corrupted
    );
  },
};
