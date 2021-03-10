//Pass order details to the next page for ordering to take place

class OrderDetails {
  final String urgency;
  final String numberofPages;
  final String documentType;
  final String subjectType;

  final String academicLevel;

  final String spacingStyle;

  OrderDetails(
    this.documentType,
    this.subjectType, 
    this.numberofPages,
      this.academicLevel,
       this.urgency, 
       this.spacingStyle
       );
}
