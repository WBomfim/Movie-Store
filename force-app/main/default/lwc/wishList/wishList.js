import { LightningElement, track } from 'lwc';
import findContacts from '@salesforce/apex/WishListBO.findContacts';
import findAllList from '@salesforce/apex/WishListBO.findAll';
import addItem from '@salesforce/apex/WishListBO.addItem';
import deleteItem from '@salesforce/apex/WishListBO.deleteItem';

export default class WishList extends LightningElement {
  @track movieName = '';
  @track contact = '';

  @track wishList = [];
  @track contactOptions = [];

  columns = [
    { label: 'Movie Name', fieldName: 'Name', editable: false },
    { label: 'Contact Name', fieldName: 'contactName', editable: false },
    {
      type: 'button-icon',
      initialWidth: 50,
      typeAttributes: {
        iconName: 'utility:delete',
        variant: 'border-filled',
        alternativeText: 'Excluir',
        title: 'Excluir'
      }
    }
  ];

  connectedCallback() {
    this.handleContctOptions();
    this.handleWhishList();
  }
  
  async handleContctOptions() {
    const contacts = await findContacts();
    this.contactOptions = contacts.map(item => {
      return { label: item.Name, value: item.Name };
    });
  }

  async handleWhishList() {
    const list = await findAllList();
    this.wishList = list.map(item => {
      return { ...item, contactName: item.ContactName__c};
    });
  }

  handleChange({ target }) {
    this[target.name] = target.value;
  }

  async handleSave() {
    if (!this.movieName) {
      const buttonElement = this.template.querySelector('button');
      buttonElement.blur();
      return;
    }
    
    await addItem({ item: this.movieName, contactName: this.contact })
    this.movieName = '';
    this.contact = '';
    this.handleWhishList();

    const buttonElement = this.template.querySelector('button');
    buttonElement.blur();
  }

  async handleRowAction({ detail }) {
    const { row } = detail;
    await deleteItem({ itemId: row.Id });
    this.handleWhishList();
  }
}
